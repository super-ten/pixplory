import { describe, expect, it } from 'vitest'
import seed from './seed.json'

describe('legacy migration', () => {
  it('contains the complete unique legacy dataset', () => {
    expect(seed.categories).toHaveLength(5)
    expect(seed.entries).toHaveLength(27)
    expect(new Set(seed.categories.map(x => x.id)).size).toBe(5)
    expect(new Set(seed.entries.map(x => x.id)).size).toBe(27)
  })

  it('keeps every entry attached to a known category', () => {
    const categoryIds = new Set(seed.categories.map(x => x.id))
    expect(seed.entries.every(x => categoryIds.has(x.category_id))).toBe(true)
  })
})
