create table if not exists public.ngombi_audience_usage_daily (
  installation_id uuid not null,
  usage_date date not null,
  section text not null check (section in ('Accueil','Radio','TV','Bouquet')),
  active_seconds bigint not null default 0 check (active_seconds >= 0),
  data_bytes bigint not null default 0 check (data_bytes >= 0),
  updated_at timestamptz not null default now(),
  primary key (installation_id, usage_date, section)
);

alter table public.ngombi_audience_usage_daily enable row level security;

create index if not exists ngombi_audience_usage_daily_date_idx
  on public.ngombi_audience_usage_daily (usage_date);

create or replace function public.ngombi_usage_record(
  p_installation_id uuid,
  p_section text,
  p_active_seconds integer,
  p_data_bytes bigint
)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_date date := (now() at time zone 'Africa/Libreville')::date;
begin
  if p_installation_id is null
     or p_section not in ('Accueil','Radio','TV','Bouquet')
     or p_active_seconds is null
     or p_active_seconds < 0
     or p_active_seconds > 300
     or p_data_bytes is null
     or p_data_bytes < 0
     or p_data_bytes > 5368709120 then
    raise exception 'Invalid NGOMBI usage sample';
  end if;

  insert into public.ngombi_audience_usage_daily
    (installation_id, usage_date, section, active_seconds, data_bytes, updated_at)
  values
    (p_installation_id, v_date, p_section, p_active_seconds, p_data_bytes, now())
  on conflict (installation_id, usage_date, section) do update
    set active_seconds = public.ngombi_audience_usage_daily.active_seconds + excluded.active_seconds,
        data_bytes = public.ngombi_audience_usage_daily.data_bytes + excluded.data_bytes,
        updated_at = now();
end;
$function$;

revoke all on function public.ngombi_usage_record(uuid,text,integer,bigint) from public;
grant execute on function public.ngombi_usage_record(uuid,text,integer,bigint) to anon, authenticated;

create or replace function public.ngombi_audience_annual_stats(p_year integer)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_result jsonb;
  v_start date;
  v_end date;
begin
  if auth.uid() is null or not exists (
    select 1 from public.ngombi_admin_users a where a.user_id = auth.uid()
  ) then
    raise exception 'Administrator access required' using errcode = '42501';
  end if;

  if p_year < 2000 or p_year > 2100 then
    raise exception 'Invalid reporting year';
  end if;

  v_start := make_date(p_year, 1, 1);
  v_end := make_date(p_year + 1, 1, 1);

  select jsonb_build_object(
    'year', p_year,
    'unique_installations', (
      select count(distinct installation_id)
      from public.ngombi_audience_usage_daily
      where usage_date >= v_start and usage_date < v_end
    ),
    'active_seconds', coalesce((
      select sum(active_seconds) from public.ngombi_audience_usage_daily
      where usage_date >= v_start and usage_date < v_end
    ), 0),
    'data_bytes', coalesce((
      select sum(data_bytes) from public.ngombi_audience_usage_daily
      where usage_date >= v_start and usage_date < v_end
    ), 0),
    'by_section', coalesce((
      select jsonb_object_agg(section, jsonb_build_object(
        'installations', installations,
        'active_seconds', active_seconds,
        'data_bytes', data_bytes
      ))
      from (
        select section,
               count(distinct installation_id)::bigint as installations,
               sum(active_seconds)::bigint as active_seconds,
               sum(data_bytes)::bigint as data_bytes
        from public.ngombi_audience_usage_daily
        where usage_date >= v_start and usage_date < v_end
        group by section
      ) s
    ), '{}'::jsonb),
    'monthly', coalesce((
      select jsonb_agg(jsonb_build_object(
        'month', month_start,
        'installations', installations,
        'active_seconds', active_seconds,
        'data_bytes', data_bytes
      ) order by month_start)
      from (
        select m::date as month_start,
               count(distinct u.installation_id)::bigint as installations,
               coalesce(sum(u.active_seconds), 0)::bigint as active_seconds,
               coalesce(sum(u.data_bytes), 0)::bigint as data_bytes
        from generate_series(v_start::timestamp, (v_end - interval '1 month')::timestamp, interval '1 month') m
        left join public.ngombi_audience_usage_daily u
          on u.usage_date >= m::date
         and u.usage_date < (m + interval '1 month')::date
        group by m
      ) months
    ), '[]'::jsonb)
  ) into v_result;

  return v_result;
end;
$function$;

revoke all on function public.ngombi_audience_annual_stats(integer) from public;
grant execute on function public.ngombi_audience_annual_stats(integer) to authenticated;
