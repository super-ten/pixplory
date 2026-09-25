create or replace function public.reorder_category_entries(
  target_category_id uuid,
  ordered_entry_ids uuid[]
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  active_entry_ids uuid[];
  submitted_entry_ids uuid[];
begin
  if auth.uid() is null then
    raise exception 'authentication required';
  end if;

  if not exists (select 1 from profiles where id = auth.uid()) then
    raise exception 'member profile required';
  end if;

  perform 1 from categories
  where id = target_category_id and deleted_at is null
  for update;
  if not found then
    raise exception 'category not found';
  end if;

  perform id from entries
  where category_id = target_category_id and deleted_at is null
  order by id
  for update;

  select coalesce(array_agg(id order by id), '{}'::uuid[])
  into active_entry_ids
  from entries
  where category_id = target_category_id and deleted_at is null;

  select coalesce(array_agg(requested.id order by requested.id), '{}'::uuid[])
  into submitted_entry_ids
  from unnest(coalesce(ordered_entry_ids, '{}'::uuid[])) as requested(id);

  if active_entry_ids is distinct from submitted_entry_ids then
    raise exception 'entry list changed; reload and try again';
  end if;

  update entries as entry
  set sort_order = requested.position::integer - 1
  from unnest(ordered_entry_ids) with ordinality as requested(id, position)
  where entry.id = requested.id
    and entry.category_id = target_category_id
    and entry.deleted_at is null
    and entry.sort_order is distinct from requested.position::integer - 1;
end;
$$;

revoke all on function public.reorder_category_entries(uuid, uuid[]) from public, anon;
grant execute on function public.reorder_category_entries(uuid, uuid[]) to authenticated;
