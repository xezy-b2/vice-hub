-- VICE HUB — schéma Supabase (système de comptes)
-- À exécuter UNE fois : Supabase → projet "vice-hub" → SQL Editor → New query → coller → Run.

-- ===== PROFILS PUBLICS =====
create table public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  username    text not null check (username ~ '^[A-Za-z0-9_]{3,20}$'),
  avatar      text not null default '🌴' check (char_length(avatar) <= 8),
  color       text not null default '#ff3d8b' check (color ~ '^#[0-9a-fA-F]{6}$'),
  bio         text not null default '' check (char_length(bio) <= 160),
  plateforme  text not null default '' check (char_length(plateforme) <= 30),
  perso       text not null default '' check (char_length(perso) <= 30),
  created_at  timestamptz not null default now()
);
create unique index profiles_username_lower_idx on public.profiles (lower(username));
alter table public.profiles enable row level security;
create policy "profiles_read_all"   on public.profiles for select to anon, authenticated using (true);
create policy "profiles_update_own" on public.profiles for update to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);

-- ===== SAUVEGARDE PRIVÉE (profil de jeu, missions, streamers, watchlist) =====
create table public.player_state (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  state      jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.player_state enable row level security;
create policy "state_select_own" on public.player_state for select to authenticated using ((select auth.uid()) = user_id);
create policy "state_insert_own" on public.player_state for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "state_update_own" on public.player_state for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "state_delete_own" on public.player_state for delete to authenticated using ((select auth.uid()) = user_id);

-- ===== CLASSEMENT =====
create table public.leaderboard (
  user_id    uuid primary key references public.profiles(id) on delete cascade,
  pct        int not null default 0 check (pct between 0 and 100),
  done       int not null default 0 check (done between 0 and 10000),
  h          numeric not null default 0 check (h between 0 and 99999),
  updated_at timestamptz not null default now()
);
alter table public.leaderboard enable row level security;
create policy "lb_read_all"   on public.leaderboard for select to anon, authenticated using (true);
create policy "lb_insert_own" on public.leaderboard for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "lb_update_own" on public.leaderboard for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "lb_delete_own" on public.leaderboard for delete to authenticated using ((select auth.uid()) = user_id);

create view public.leaderboard_public with (security_invoker = true) as
  select l.user_id, p.username, p.avatar, p.color, p.plateforme, p.perso, l.pct, l.done, l.h, l.updated_at
  from public.leaderboard l join public.profiles p on p.id = l.user_id;
grant select on public.leaderboard_public to anon, authenticated;

-- ===== CRÉATION AUTOMATIQUE DU PROFIL À L'INSCRIPTION =====
create function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  base text;
  candidate text;
  n int := 0;
begin
  base := coalesce(
    new.raw_user_meta_data->>'username',
    new.raw_user_meta_data->>'user_name',
    new.raw_user_meta_data->>'preferred_username',
    new.raw_user_meta_data->>'name',
    split_part(coalesce(new.email, ''), '@', 1)
  );
  base := regexp_replace(coalesce(base, ''), '[^A-Za-z0-9_]', '', 'g');
  if char_length(base) < 3 then base := 'joueur' || base; end if;
  base := left(base, 16);
  candidate := base;
  while exists (select 1 from public.profiles where lower(username) = lower(candidate)) loop
    n := n + 1;
    candidate := left(base, 15) || '_' || (floor(random() * 900) + 100)::int;
    exit when n > 20;
  end loop;
  insert into public.profiles (id, username) values (new.id, candidate);
  return new;
end;
$$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();
revoke execute on function public.handle_new_user() from public, anon, authenticated;

-- ===== DISPONIBILITÉ D'UN PSEUDO =====
create function public.username_available(name text) returns boolean
language sql stable security definer set search_path = '' as $$
  select name ~ '^[A-Za-z0-9_]{3,20}$'
     and not exists (select 1 from public.profiles where lower(username) = lower(name));
$$;
grant execute on function public.username_available(text) to anon, authenticated;

-- ===== SUPPRESSION DE SON PROPRE COMPTE =====
create function public.delete_my_account() returns void
language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then raise exception 'not authenticated'; end if;
  delete from auth.users where id = auth.uid();
end;
$$;
revoke execute on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
