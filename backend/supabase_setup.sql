-- المحقق فلفل — Supabase Cloud Save setup
-- شغّل الملف ده مرة واحدة في Supabase SQL Editor.

create table if not exists public.game_saves (
    user_id uuid primary key references auth.users(id) on delete cascade,
    save_data jsonb not null default '{}'::jsonb,
    updated_at timestamptz not null default now()
);

alter table public.game_saves enable row level security;

grant select, insert, update on table public.game_saves to authenticated;

drop policy if exists "game_saves_select_own" on public.game_saves;
create policy "game_saves_select_own"
on public.game_saves
for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "game_saves_insert_own" on public.game_saves;
create policy "game_saves_insert_own"
on public.game_saves
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "game_saves_update_own" on public.game_saves;
create policy "game_saves_update_own"
on public.game_saves
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create or replace function public.set_game_saves_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

drop trigger if exists set_game_saves_updated_at on public.game_saves;
create trigger set_game_saves_updated_at
before update on public.game_saves
for each row
execute function public.set_game_saves_updated_at();
