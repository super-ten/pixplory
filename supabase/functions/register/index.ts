import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, json } from '../_shared/cors.ts'

Deno.serve(async request => {
  if (request.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders(request) })
  if (request.method !== 'POST') return json(request, { error: 'method not allowed' }, 405)
  try {
    const { username, displayName, email, password, inviteCode } = await request.json()
    if (!/^[A-Za-z0-9_]{3,32}$/.test(username || '')) return json(request, { error: '用户名须为 3–32 位字母、数字或下划线' }, 400)
    if (!displayName || displayName.trim().length < 2) return json(request, { error: '请填写实名显示名' }, 400)
    if (!email || !password || password.length < 8) return json(request, { error: '请填写有效邮箱和至少 8 位密码' }, 400)
    if (!Deno.env.get('APP_INVITE_CODE') || inviteCode !== Deno.env.get('APP_INVITE_CODE')) return json(request, { error: '邀请码不正确' }, 403)

    const admin = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, { auth: { autoRefreshToken: false, persistSession: false } })
    const { data: existing } = await admin.from('profiles').select('id').eq('username', username.toLowerCase()).maybeSingle()
    if (existing) return json(request, { error: '用户名已被使用' }, 409)
    const { data, error } = await admin.auth.admin.createUser({ email: email.trim().toLowerCase(), password, email_confirm: true })
    if (error) return json(request, { error: error.message }, 400)
    const { error: profileError } = await admin.rpc('register_profile', { new_user_id: data.user.id, new_username: username, new_display_name: displayName })
    if (profileError) {
      await admin.auth.admin.deleteUser(data.user.id)
      return json(request, { error: profileError.message }, 400)
    }
    return json(request, { ok: true }, 201)
  } catch { return json(request, { error: '注册请求格式不正确' }, 400) }
})
