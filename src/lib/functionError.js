export async function getFunctionErrorMessage(error, data, fallback = '请求失败，请稍后重试') {
  if (data?.error) return data.error
  if (data?.message) return data.message

  const response = error?.context
  if (response && typeof response.clone === 'function') {
    try {
      const payload = await response.clone().json()
      if (payload?.error) return payload.error
      if (payload?.message) return payload.message
    } catch {
      // The response may not contain JSON. Fall through to the SDK message.
    }
  }

  return error?.message || fallback
}
