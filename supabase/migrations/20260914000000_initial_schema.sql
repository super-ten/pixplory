create extension if not exists pgcrypto;
create extension if not exists citext;

create type public.app_role as enum ('member', 'admin');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username citext not null unique check (username ~ '^[A-Za-z0-9_]{3,32}$'),
  display_name text not null check (char_length(display_name) between 2 and 50),
  role public.app_role not null default 'member',
  created_at timestamptz not null default now()
);

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  headers jsonb not null default '["核心術語 / 簡稱","國際生態 / 英文全稱","國內對標 / 中文名稱","學術釋義與應用語境"]'::jsonb,
  sort_order integer not null default 0,
  revision integer not null default 1,
  updated_by uuid references public.profiles(id),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  check (jsonb_typeof(headers) = 'array' and jsonb_array_length(headers) = 4)
);

create table public.entries (
  id uuid primary key default gen_random_uuid(),
  category_id uuid not null references public.categories(id),
  term text not null default '',
  intl text not null default '',
  cn text not null default '',
  description text not null default '',
  sort_order integer not null default 0,
  revision integer not null default 1,
  updated_by uuid references public.profiles(id),
  last_editor_name text,
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.entry_notes (
  entry_id uuid primary key references public.entries(id) on delete cascade,
  note text not null default '',
  prompt text not null default '',
  skill_urls jsonb not null default '[]'::jsonb,
  markdown text not null default '',
  revision integer not null default 1,
  updated_by uuid references public.profiles(id),
  updated_at timestamptz not null default now(),
  check (jsonb_typeof(skill_urls) = 'array')
);

create table public.change_history (
  id bigint generated always as identity primary key,
  entity_type text not null,
  entity_id uuid not null,
  action text not null,
  field_name text,
  old_value jsonb,
  new_value jsonb,
  actor_id uuid references public.profiles(id),
  actor_name text,
  created_at timestamptz not null default now()
);

create table public.snapshots (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null default '',
  state jsonb not null,
  created_by uuid not null references public.profiles(id),
  creator_name text not null,
  created_at timestamptz not null default now()
);

create index entries_category_order_idx on public.entries(category_id, sort_order) where deleted_at is null;
create index change_history_created_idx on public.change_history(created_at desc);
create index snapshots_created_idx on public.snapshots(created_at desc);

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public
as $$ select exists(select 1 from profiles where id = auth.uid() and role = 'admin') $$;

create or replace function public.register_profile(new_user_id uuid, new_username text, new_display_name text)
returns public.profiles language plpgsql security definer set search_path = public
as $$
declare created_profile public.profiles;
begin
  perform pg_advisory_xact_lock(728194);
  if auth.role() <> 'service_role' then raise exception 'service role required'; end if;
  insert into profiles(id, username, display_name, role)
  values (new_user_id, lower(trim(new_username)), trim(new_display_name),
    case when not exists(select 1 from profiles where role = 'admin') then 'admin'::app_role else 'member'::app_role end)
  returning * into created_profile;
  return created_profile;
end $$;

create or replace function public.set_change_metadata()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  new.updated_at := now();
  new.updated_by := auth.uid();
  if tg_op = 'UPDATE' then new.revision := old.revision + 1; end if;
  if tg_table_name = 'entries' then
    select display_name into new.last_editor_name from profiles where id = auth.uid();
  end if;
  return new;
end $$;

create trigger categories_metadata before insert or update on public.categories for each row execute function public.set_change_metadata();
create trigger entries_metadata before insert or update on public.entries for each row execute function public.set_change_metadata();
create trigger notes_metadata before insert or update on public.entry_notes for each row execute function public.set_change_metadata();

create or replace function public.audit_change()
returns trigger language plpgsql security definer set search_path = public
as $$
declare old_doc jsonb; new_doc jsonb; actor text; key text; entity_key uuid;
begin
  old_doc := case when tg_op = 'INSERT' then null else to_jsonb(old) end;
  new_doc := case when tg_op = 'DELETE' then null else to_jsonb(new) end;
  select display_name into actor from profiles where id = auth.uid();
  entity_key := case
    when tg_table_name = 'entry_notes' then coalesce((new_doc->>'entry_id')::uuid,(old_doc->>'entry_id')::uuid)
    else coalesce((new_doc->>'id')::uuid,(old_doc->>'id')::uuid)
  end;
  if tg_op = 'UPDATE' then
    for key in select jsonb_object_keys(new_doc) loop
      if key not in ('updated_at','updated_by','revision','last_editor_name') and old_doc->key is distinct from new_doc->key then
        insert into change_history(entity_type,entity_id,action,field_name,old_value,new_value,actor_id,actor_name)
        values(tg_table_name,entity_key,'update',key,old_doc->key,new_doc->key,auth.uid(),actor);
      end if;
    end loop;
  else
    insert into change_history(entity_type,entity_id,action,old_value,new_value,actor_id,actor_name)
    values(tg_table_name,entity_key,lower(tg_op),old_doc,new_doc,auth.uid(),actor);
  end if;
  return coalesce(new,old);
end $$;

create trigger categories_audit after insert or update or delete on public.categories for each row execute function public.audit_change();
create trigger entries_audit after insert or update or delete on public.entries for each row execute function public.audit_change();
create trigger notes_audit after insert or update or delete on public.entry_notes for each row execute function public.audit_change();

create or replace function public.update_entry_field(target_id uuid, target_field text, new_value text, expected_revision integer)
returns public.entries language plpgsql security invoker set search_path = public
as $$
declare result public.entries;
begin
  if target_field not in ('term','intl','cn','description') then raise exception 'invalid field'; end if;
  execute format('update entries set %I = $1 where id = $2 and revision = $3 and deleted_at is null returning *', target_field)
    into result using new_value, target_id, expected_revision;
  if result.id is null then raise exception 'revision conflict'; end if;
  return result;
end $$;

create or replace function public.create_snapshot(snapshot_name text, snapshot_description text default '')
returns uuid language plpgsql security definer set search_path = public
as $$
declare snapshot_id uuid; actor text;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  select display_name into actor from profiles where id = auth.uid();
  insert into snapshots(name,description,state,created_by,creator_name)
  select coalesce(nullif(trim(snapshot_name),''),'手动快照'),coalesce(snapshot_description,''),jsonb_build_object(
    'categories',coalesce((select jsonb_agg(to_jsonb(c) order by sort_order) from categories c),'[]'::jsonb),
    'entries',coalesce((select jsonb_agg(to_jsonb(e) order by category_id,sort_order) from entries e),'[]'::jsonb),
    'notes',coalesce((select jsonb_agg(to_jsonb(n)) from entry_notes n),'[]'::jsonb)
  ),auth.uid(),actor returning id into snapshot_id;
  return snapshot_id;
end $$;

create or replace function public.restore_snapshot(target_snapshot_id uuid)
returns void language plpgsql security definer set search_path = public
as $$
declare target jsonb; restore_point uuid;
begin
  if not is_admin() then raise exception 'administrator required'; end if;
  restore_point := create_snapshot('恢复前自动快照','系统在恢复版本前自动创建');
  select state into target from snapshots where id = target_snapshot_id;
  if target is null then raise exception 'snapshot not found'; end if;
  update categories set deleted_at = now() where true;
  update entries set deleted_at = now() where true;
  insert into categories(id,title,headers,sort_order,deleted_at)
  select id,title,headers,sort_order,deleted_at from jsonb_to_recordset(target->'categories') as x(id uuid,title text,headers jsonb,sort_order int,deleted_at timestamptz)
  on conflict(id) do update set title=excluded.title,headers=excluded.headers,sort_order=excluded.sort_order,deleted_at=excluded.deleted_at;
  insert into entries(id,category_id,term,intl,cn,description,sort_order,deleted_at)
  select id,category_id,term,intl,cn,description,sort_order,deleted_at from jsonb_to_recordset(target->'entries') as x(id uuid,category_id uuid,term text,intl text,cn text,description text,sort_order int,deleted_at timestamptz)
  on conflict(id) do update set category_id=excluded.category_id,term=excluded.term,intl=excluded.intl,cn=excluded.cn,description=excluded.description,sort_order=excluded.sort_order,deleted_at=excluded.deleted_at;
  insert into entry_notes(entry_id,note,prompt,skill_urls,markdown)
  select entry_id,note,prompt,skill_urls,markdown from jsonb_to_recordset(target->'notes') as x(entry_id uuid,note text,prompt text,skill_urls jsonb,markdown text)
  on conflict(entry_id) do update set note=excluded.note,prompt=excluded.prompt,skill_urls=excluded.skill_urls,markdown=excluded.markdown;
end $$;

create or replace function public.import_workspace(import_state jsonb)
returns void language plpgsql security definer set search_path = public
as $$
begin
  if not is_admin() then raise exception 'administrator required'; end if;
  perform create_snapshot('导入前自动快照','系统在全量导入前自动创建');
  if jsonb_typeof(import_state->'categories') <> 'array' or jsonb_typeof(import_state->'entries') <> 'array' then
    raise exception 'invalid import format';
  end if;
  update categories set deleted_at = now() where true;
  update entries set deleted_at = now() where true;
  insert into categories(id,title,headers,sort_order,deleted_at)
  select id,title,headers,sort_order,null from jsonb_to_recordset(import_state->'categories') as x(id uuid,title text,headers jsonb,sort_order int)
  on conflict(id) do update set title=excluded.title,headers=excluded.headers,sort_order=excluded.sort_order,deleted_at=null;
  insert into entries(id,category_id,term,intl,cn,description,sort_order,deleted_at)
  select id,category_id,term,intl,cn,description,sort_order,null from jsonb_to_recordset(import_state->'entries') as x(id uuid,category_id uuid,term text,intl text,cn text,description text,sort_order int)
  on conflict(id) do update set category_id=excluded.category_id,term=excluded.term,intl=excluded.intl,cn=excluded.cn,description=excluded.description,sort_order=excluded.sort_order,deleted_at=null;
end $$;

alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.entries enable row level security;
alter table public.entry_notes enable row level security;
alter table public.change_history enable row level security;
alter table public.snapshots enable row level security;

revoke all on all tables in schema public from anon, authenticated;
grant select on public.categories, public.entries to anon, authenticated;
grant select on public.profiles, public.entry_notes, public.change_history, public.snapshots to authenticated;
grant insert, update on public.categories, public.entries, public.entry_notes to authenticated;
grant insert on public.snapshots to authenticated;
grant usage, select on sequence public.change_history_id_seq to authenticated;
grant execute on function public.update_entry_field(uuid,text,text,integer), public.create_snapshot(text,text), public.restore_snapshot(uuid), public.import_workspace(jsonb) to authenticated;

create policy profiles_member_read on public.profiles for select to authenticated using (true);
create policy public_categories_read on public.categories for select to anon using (deleted_at is null);
create policy member_categories_read on public.categories for select to authenticated using (true);
create policy member_categories_insert on public.categories for insert to authenticated with check (true);
create policy member_categories_update on public.categories for update to authenticated using (true) with check (true);
create policy public_entries_read on public.entries for select to anon using (deleted_at is null);
create policy member_entries_read on public.entries for select to authenticated using (true);
create policy member_entries_insert on public.entries for insert to authenticated with check (true);
create policy member_entries_update on public.entries for update to authenticated using (true) with check (true);
create policy member_notes_read on public.entry_notes for select to authenticated using (true);
create policy member_notes_insert on public.entry_notes for insert to authenticated with check (true);
create policy member_notes_update on public.entry_notes for update to authenticated using (true) with check (true);
create policy member_history_read on public.change_history for select to authenticated using (true);
create policy member_snapshots_read on public.snapshots for select to authenticated using (true);
create policy member_snapshots_insert on public.snapshots for insert to authenticated with check (created_by = auth.uid());

alter publication supabase_realtime add table public.categories;
alter publication supabase_realtime add table public.entries;

create policy "members receive workspace events" on realtime.messages for select to authenticated using (realtime.topic() = 'workspace:main');
create policy "members send workspace presence" on realtime.messages for insert to authenticated with check (realtime.topic() = 'workspace:main' and realtime.messages.extension = 'presence');
