import { describe, expect, it } from 'vitest'
import { getFunctionErrorMessage } from './functionError'

describe('getFunctionErrorMessage', () => {
  it('prefers the function response body', async () => {
    const error = { message: 'Edge Function returned a non-2xx status code', context: new Response(JSON.stringify({ error: '用户名或密码错误' })) }
    await expect(getFunctionErrorMessage(error)).resolves.toBe('用户名或密码错误')
  })

  it('uses successful response data when present', async () => {
    await expect(getFunctionErrorMessage(null, { error: '邀请码不正确' })).resolves.toBe('邀请码不正确')
  })
})
