begin;

insert into public.entries (id, category_id, term, intl, cn, description, sort_order)
values (
  'd3000012-0000-4000-8000-000000000012'::uuid,
  'fd1a19f7-5c41-4dca-9c1f-5113be2eb186'::uuid,
  'ControlNet 3D',
  'Blender＋Sora、Veo、Runway',
  '3D 預演控制；Blender＋即夢',
  '先用 Blender 等軟件以簡化幾何和攝影機運動完成 3D 預演，再將動畫與風格提示交給 AI 視頻模型，在保持鏡頭軌跡和場景佈局的基礎上生成高質量成片。',
  14
)
on conflict (id) do update set
  term = excluded.term,
  intl = excluded.intl,
  cn = excluded.cn,
  description = excluded.description,
  sort_order = excluded.sort_order,
  deleted_at = null,
  updated_at = now(),
  revision = public.entries.revision + 1;

commit;
