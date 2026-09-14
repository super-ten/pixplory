import { corsHeaders, json } from '../_shared/cors.ts'

Deno.serve(async request => {
  if (request.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders(request) })
  if (request.method !== 'POST') return json(request, { error: 'method not allowed' }, 405)
  try {
    const { username, password } = await request.json()
    if (!username || !password) return json(request, { error: '请输入用户名和密码' }, 400)
    const url = Deno.env.get('SUPABASE_URL')!
    const secretKeys = JSON.parse(Deno.env.get('SUPABASE_SECRET_KEYS') || '{}')
    const secretKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || secretKeys['default']
    if (!secretKey) return json(request, { error: '登录服务配置不完整' }, 500)
    const adminHeaders = { apikey: secretKey, Authorization: `Bearer ${secretKey}` }
    const profileResponse = await fetch(`${url}/rest/v1/profiles?username=eq.${encodeURIComponent(username.toLowerCase())}&select=id&limit=1`, {
      headers: adminHeaders
    })
    if (!profileResponse.ok) return json(request, { error: '登录服务暂时不可用' }, 500)
    const [profile] = await profileResponse.json()
    if (!profile) return json(request, { error: '用户名或密码错误' }, 401)
    const userResponse = await fetch(`${url}/auth/v1/admin/users/${profile.id}`, { headers: adminHeaders })
    if (!userResponse.ok) return json(request, { error: '登录服务暂时不可用' }, 500)
    const email = (await userResponse.json())?.email
    if (!email) return json(request, { error: '用户名或密码错误' }, 401)
    // Supabase password grants require a publishable/anon client key. New
    // projects may not expose the legacy SUPABASE_ANON_KEY environment value,
    // so use the publishable key already validated by the function gateway.
    const publishableKeys = JSON.parse(Deno.env.get('SUPABASE_PUBLISHABLE_KEYS') || '{}')
    const publishableKey = Object.values(publishableKeys).find(value => typeof value === 'string') as string | undefined
    if (!publishableKey) return json(request, { error: '登录服务配置不完整' }, 500)
    const authResponse = await fetch(`${url}/auth/v1/token?grant_type=password`, {
      method: 'POST', headers: { apikey: publishableKey, 'Content-Type': 'application/json' }, body: JSON.stringify({ email, password })
    })
    if (!authResponse.ok) return json(request, { error: '用户名或密码错误' }, 401)
    const session = await authResponse.json()
    return json(request, { access_token: session.access_token, refresh_token: session.refresh_token })
  } catch { return json(request, { error: '登录请求格式不正确' }, 400) }
})
