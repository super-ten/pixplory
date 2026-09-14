import { describe, expect, it } from 'vitest'
import seed from './seed.json'

describe('legacy migration', () => {
  it('contains the complete unique legacy dataset', () => {
    expect(seed.categories).toHaveLength(5)
    expect(seed.entries).toHaveLength(59)
    expect(new Set(seed.categories.map(x => x.id)).size).toBe(5)
    expect(new Set(seed.entries.map(x => x.id)).size).toBe(59)
  })

  it('keeps every entry attached to a known category', () => {
    const categoryIds = new Set(seed.categories.map(x => x.id))
    expect(seed.entries.every(x => categoryIds.has(x.category_id))).toBe(true)
  })

  it('keeps the visual-generation columns structurally consistent', () => {
    const visualCategoryId = 'fd1a19f7-5c41-4dca-9c1f-5113be2eb186'
    const entries = seed.entries.filter(x => x.category_id === visualCategoryId)

    expect(entries).toHaveLength(15)
    expect(entries.every(x => x.intl.length > 0)).toBe(true)
    expect(entries.every(x => x.cn.includes('；'))).toBe(true)
  })
})
