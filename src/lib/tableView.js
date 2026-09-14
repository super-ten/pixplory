export const COLLAPSED_ENTRY_COUNT = 3

export function getVisibleEntries(entries, expanded) {
  return expanded ? entries : entries.slice(0, COLLAPSED_ENTRY_COUNT)
}

export function isBinaryStatusField(categoryIndex, field) {
  return (categoryIndex === 3 || categoryIndex === 4) && (field === 'intl' || field === 'cn')
}

export function normalizeBinaryStatus(value) {
  return value === '☑️' ? '☑️' : '✖️'
}

export function getNextBinaryStatus(value) {
  return normalizeBinaryStatus(value) === '☑️' ? '✖️' : '☑️'
}
