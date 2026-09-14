import { readFile, writeFile, mkdir } from 'node:fs/promises'
import { randomUUID } from 'node:crypto'

const source = new URL('../AI全棧創作索引.html', import.meta.url)
const html = await readFile(source, 'utf8')
const match = html.match(/<script id="app-data" type="application\/json">([\s\S]*?)<\/script>/)
if (!match) throw new Error('找不到原始 HTML 中的 app-data')
const legacy = JSON.parse(match[1])
const titles = [...new Set(legacy.rows.map(row => row.category))]
const categories = titles.map((title, sort_order) => ({
  id: randomUUID(), title, headers: legacy.headers[title] || ['核心術語 / 簡稱', '國際生態 / 英文全稱', '國內對標 / 中文名稱', '學術釋義與應用語境'], sort_order, revision: 1
}))
const categoryIds = Object.fromEntries(categories.map(item => [item.title, item.id]))
const entryCounts = {}
const entries = legacy.rows.map(row => ({
  id: randomUUID(),
  category_id: categoryIds[row.category],
  term: row.term || '', intl: row.intl || '', cn: row.cn || '', description: row.desc || '',
  sort_order: entryCounts[row.category] = (entryCounts[row.category] ?? -1) + 1,
  revision: 1,
  legacy_ai_insight: row.aiInsight || ''
}))
const seed = { categories, entries: entries.map(({ legacy_ai_insight, ...entry }) => entry) }
await mkdir(new URL('../src/data/', import.meta.url), { recursive: true })
await writeFile(new URL('../src/data/seed.json', import.meta.url), `${JSON.stringify(seed, null, 2)}\n`)

const quote = value => `'${String(value ?? '').replaceAll("'", "''")}'`
const sql = [
  '-- Generated from AI全棧創作索引.html by npm run extract:legacy',
  'begin;',
  ...categories.map(c => `insert into public.categories (id,title,headers,sort_order) values (${quote(c.id)}::uuid,${quote(c.title)},${quote(JSON.stringify(c.headers))}::jsonb,${c.sort_order}) on conflict (id) do nothing;`),
  ...entries.map(e => `insert into public.entries (id,category_id,term,intl,cn,description,sort_order) values (${quote(e.id)}::uuid,${quote(e.category_id)}::uuid,${quote(e.term)},${quote(e.intl)},${quote(e.cn)},${quote(e.description)},${e.sort_order}) on conflict (id) do nothing;`),
  ...entries.filter(e => e.legacy_ai_insight).map(e => `insert into public.entry_notes (entry_id,note) values (${quote(e.id)}::uuid,${quote(e.legacy_ai_insight)}) on conflict (entry_id) do nothing;`),
  'commit;', ''
].join('\n')
await mkdir(new URL('../supabase/', import.meta.url), { recursive: true })
await writeFile(new URL('../supabase/seed.sql', import.meta.url), sql)
console.log(`已提取 ${categories.length} 个分类、${entries.length} 个条目。`)
