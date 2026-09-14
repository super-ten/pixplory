import { describe, expect, it, vi } from 'vitest'
import { downloadMarkdown, readMarkdown } from './markdown'

describe('Markdown exchange', () => {
  it('accepts .md files and keeps unicode content', async () => {
    const file = new File(['# 提示词\n你好'], 'Skill.md', { type: 'text/markdown' })
    await expect(readMarkdown(file)).resolves.toBe('# 提示词\n你好')
  })

  it('rejects unrelated files', async () => {
    const file = new File(['x'], 'note.exe', { type: 'application/octet-stream' })
    await expect(readMarkdown(file)).rejects.toThrow('Markdown')
  })

  it('downloads with a safe markdown filename', () => {
    Object.defineProperty(URL, 'createObjectURL', { configurable: true, value: vi.fn(() => 'blob:test') })
    Object.defineProperty(URL, 'revokeObjectURL', { configurable: true, value: vi.fn() })
    const click = vi.spyOn(HTMLAnchorElement.prototype, 'click').mockImplementation(() => {})
    const create = vi.spyOn(URL, 'createObjectURL').mockReturnValue('blob:test')
    const revoke = vi.spyOn(URL, 'revokeObjectURL').mockImplementation(() => {})
    downloadMarkdown('A / B', '正文')
    expect(click).toHaveBeenCalledOnce()
    create.mockRestore(); revoke.mockRestore(); click.mockRestore()
  })
})
