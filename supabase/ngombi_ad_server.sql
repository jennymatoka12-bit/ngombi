-- NGOMBI AD SERVER V2
-- À exécuter dans le SQL Editor du projet Supabase.

create extension if not exists pgcrypto;

create table if not exists public.ngombi_admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.ngombi_ad_campaigns (
  id text primary key,
  title text not null,
  type text not null check (type in ('image', 'video')),
  media text not null,
  duration_seconds integer not null default 15 check (duration_seconds > 0),
  click_url text not null default '',
  active boolean not null default true,
  priority integer not null default 0,
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.ngombi_admin_users enable row level security;
alter table public.ngombi_ad_campaigns enable row level security;

revoke all on public.ngombi_admin_users from anon, authenticated;
revoke all on public.ngombi_ad_campaigns from anon;

grant select on public.ngombi_ad_campaigns to anon;
grant select, insert, update, delete on public.ngombi_ad_campaigns to authenticated;

drop policy if exists "public can read active NGOMBI ads" on public.ngombi_ad_campaigns;
create policy "public can read active NGOMBI ads"
on public.ngombi_ad_campaigns
for select
to anon
using (
  active = true
  and (starts_at is null or starts_at <= now())
  and (ends_at is null or ends_at >= now())
);

drop policy if exists "only NGOMBI admin can read campaigns" on public.ngombi_ad_campaigns;
create policy "only NGOMBI admin can read campaigns"
on public.ngombi_ad_campaigns
for select
to authenticated
using (
  exists (
    select 1 from public.ngombi_admin_users a
    where a.user_id = auth.uid()
  )
);

drop policy if exists "only NGOMBI admin can insert campaigns" on public.ngombi_ad_campaigns;
create policy "only NGOMBI admin can insert campaigns"
on public.ngombi_ad_campaigns
for insert
to authenticated
with check (
  exists (
    select 1 from public.ngombi_admin_users a
    where a.user_id = auth.uid()
  )
);

drop policy if exists "only NGOMBI admin can update campaigns" on public.ngombi_ad_campaigns;
create policy "only NGOMBI admin can update campaigns"
on public.ngombi_ad_campaigns
for update
to authenticated
using (
  exists (
    select 1 from public.ngombi_admin_users a
    where a.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.ngombi_admin_users a
    where a.user_id = auth.uid()
  )
);

drop policy if exists "only NGOMBI admin can delete campaigns" on public.ngombi_ad_campaigns;
create policy "only NGOMBI admin can delete campaigns"
on public.ngombi_ad_campaigns
for delete
to authenticated
using (
  exists (
    select 1 from public.ngombi_admin_users a
    where a.user_id = auth.uid()
  )
);

-- Après création de TON utilisateur dans Supabase Auth,
-- remplace USER_UUID_HERE par son UUID puis exécute:
-- insert into public.ngombi_admin_users(user_id) values ('USER_UUID_HERE')
-- on conflict do nothing;

-- V2 validation build trigger
