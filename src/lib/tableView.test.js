import { describe, expect, it } from 'vitest'
import {
  COLLAPSED_ENTRY_COUNT,
  getNextBinaryStatus,
  getVisibleEntries,
  isBinaryStatusField,
  normalizeBinaryStatus
} from './tableView'

describe('table view helpers', () => {
  const entries = Array.from({ length: 6 }, (_, id) => ({ id }))

  it('shows three content rows while collapsed and all rows while expanded', () => {
    expect(COLLAPSED_ENTRY_COUNT).toBe(3)
    expect(getVisibleEntries(entries, false)).toEqual(entries.slice(0, 3))
    expect(getVisibleEntries(entries, true)).toEqual(entries)
  })

  it('limits binary controls to the two status columns in modules four and five', () => {
    expect(isBinaryStatusField(3, 'intl')).toBe(true)
    expect(isBinaryStatusField(4, 'cn')).toBe(true)
    expect(isBinaryStatusField(2, 'intl')).toBe(false)
    expect(isBinaryStatusField(3, 'description')).toBe(false)
  })

  it('treats legacy values as an unchecked state and toggles both ways', () => {
    expect(normalizeBinaryStatus('-')).toBe('✖️')
    expect(getNextBinaryStatus('-')).toBe('☑️')
    expect(getNextBinaryStatus('☑️')).toBe('✖️')
  })
})
