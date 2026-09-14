export function downloadMarkdown(filename, content) {
  const blob = new Blob([content || ''], { type: 'text/markdown;charset=utf-8' })
  const href = URL.createObjectURL(blob)
  const anchor = document.createElement('a')
  anchor.href = href
  anchor.download = `${(filename || 'pixplory-note').replace(/[^\p{L}\p{N}_-]+/gu, '-')}.md`
  anchor.click()
  URL.revokeObjectURL(href)
}

export function readMarkdown(file) {
  if (!file || (!file.name.toLowerCase().endsWith('.md') && file.type !== 'text/markdown')) {
    return Promise.reject(new Error('请选择 Markdown 文件'))
  }
  if (typeof file.text === 'function') return file.text()
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = () => resolve(String(reader.result || ''))
    reader.onerror = () => reject(reader.error || new Error('无法读取文件'))
    reader.readAsText(file)
  })
}

export function downloadJson(filename, value) {
  const blob = new Blob([JSON.stringify(value, null, 2)], { type: 'application/json;charset=utf-8' })
  const href = URL.createObjectURL(blob)
  const anchor = document.createElement('a')
  anchor.href = href
  anchor.download = `${filename}.json`
  anchor.click()
  URL.revokeObjectURL(href)
}
