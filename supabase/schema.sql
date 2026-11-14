-- VICE HUB — schéma Supabase
-- À exécuter une seule fois : Supabase → SQL Editor → New query → coller → Run.

-- 1) Sauvegarde personnelle (profil, missions, streamers, watchlist)
create table if not exists public.player_state (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  state      jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.player_state enable row level security;

drop policy if exists "state_select_own" on public.player_state;
drop policy if exists "state_insert_own" on public.player_state;
drop policy if exists "state_update_own" on public.player_state;
drop policy if exists "state_delete_own" on public.player_state;
create policy "state_select_own" on public.player_state for select to authenticated using (auth.uid() = user_id);
create policy "state_insert_own" on public.player_state for insert to authenticated with check (auth.uid() = user_id);
create policy "state_update_own" on public.player_state for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "state_delete_own" on public.player_state for delete to authenticated using (auth.uid() = user_id);

-- 2) Classement communauté (lecture publique, chacun n'écrit que sa ligne)
create table if not exists public.leaderboard (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  pseudo     text not null check (char_length(pseudo) between 1 and 24),
  plat       text check (char_length(plat) <= 30),
  perso      text check (char_length(perso) <= 30),
  pct        int  not null default 0 check (pct between 0 and 100),
  done       int  not null default 0 check (done between 0 and 10000),
  h          numeric not null default 0 check (h between 0 and 99999),
  updated_at timestamptz not null default now()
);
alter table public.leaderboard enable row level security;

drop policy if exists "lb_read_all"   on public.leaderboard;
drop policy if exists "lb_insert_own" on public.leaderboard;
drop policy if exists "lb_update_own" on public.leaderboard;
drop policy if exists "lb_delete_own" on public.leaderboard;
create policy "lb_read_all"   on public.leaderboard for select to anon, authenticated using (true);
create policy "lb_insert_own" on public.leaderboard for insert to authenticated with check (auth.uid() = user_id);
create policy "lb_update_own" on public.leaderboard for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "lb_delete_own" on public.leaderboard for delete to authenticated using (auth.uid() = user_id);
