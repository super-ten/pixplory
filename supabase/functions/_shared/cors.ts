const allowed = new Set([
  'http://localhost:5173',
  // GitHub Pages may serve the custom domain over HTTP briefly while its
  // certificate is being issued. Keep registration usable during that window.
  'http://pixplory.com',
  'http://www.pixplory.com',
  'https://pixplory.com',
  'https://www.pixplory.com'
])

export function corsHeaders(request: Request) {
  const origin = request.headers.get('origin') || ''
  return {
    'Access-Control-Allow-Origin': allowed.has(origin) ? origin : 'https://pixplory.com',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Vary': 'Origin'
  }
}

export function json(request: Request, body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { ...corsHeaders(request), 'Content-Type': 'application/json' } })
}
