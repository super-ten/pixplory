import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, json } from '../_shared/cors.ts'

Deno.serve(async request => {
  if (request.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders(request) })
  if (request.method !== 'POST') return json(request, { error: 'method not allowed' }, 405)
  try {
    const { username, password } = await request.json()
    if (!username || !password) return json(request, { error: '请输入用户名和密码' }, 400)
    const url = Deno.env.get('SUPABASE_URL')!
    const admin = createClient(url, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, { auth: { autoRefreshToken: false, persistSession: false } })
    const { data: profile } = await admin.from('profiles').select('id').eq('username', username.toLowerCase()).maybeSingle()
    if (!profile) return json(request, { error: '用户名或密码错误' }, 401)
    const { data: userData } = await admin.auth.admin.getUserById(profile.id)
    const email = userData.user?.email
    if (!email) return json(request, { error: '用户名或密码错误' }, 401)
    const client = createClient(url, Deno.env.get('SUPABASE_ANON_KEY')!, { auth: { autoRefreshToken: false, persistSession: false } })
    const { data, error } = await client.auth.signInWithPassword({ email, password })
    if (error || !data.session) return json(request, { error: '用户名或密码错误' }, 401)
    return json(request, { access_token: data.session.access_token, refresh_token: data.session.refresh_token })
  } catch { return json(request, { error: '登录请求格式不正确' }, 400) }
})
