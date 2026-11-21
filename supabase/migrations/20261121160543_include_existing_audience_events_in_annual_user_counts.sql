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
      from (
        select installation_id
        from public.ngombi_audience_usage_daily
        where usage_date >= v_start and usage_date < v_end
        union all
        select installation_id
        from public.ngombi_audience_events
        where occurred_at >= v_start and occurred_at < v_end
      ) all_activity
    ),
    'active_seconds', coalesce((
      select sum(active_seconds)
      from public.ngombi_audience_usage_daily
      where usage_date >= v_start and usage_date < v_end
    ), 0),
    'data_bytes', coalesce((
      select sum(data_bytes)
      from public.ngombi_audience_usage_daily
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
        from (
          select installation_id, section, active_seconds, data_bytes
          from public.ngombi_audience_usage_daily
          where usage_date >= v_start and usage_date < v_end
          union all
          select installation_id, section, 0::bigint, 0::bigint
          from public.ngombi_audience_events
          where occurred_at >= v_start and occurred_at < v_end
        ) section_activity
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
               count(distinct a.installation_id)::bigint as installations,
               coalesce(sum(a.active_seconds), 0)::bigint as active_seconds,
               coalesce(sum(a.data_bytes), 0)::bigint as data_bytes
        from generate_series(v_start::timestamp, (v_end - interval '1 month')::timestamp, interval '1 month') m
        left join (
          select installation_id, usage_date as activity_date, active_seconds, data_bytes
          from public.ngombi_audience_usage_daily
          where usage_date >= v_start and usage_date < v_end
          union all
          select installation_id, occurred_at::date, 0::bigint, 0::bigint
          from public.ngombi_audience_events
          where occurred_at >= v_start and occurred_at < v_end
        ) a on a.activity_date >= m::date
           and a.activity_date < (m + interval '1 month')::date
        group by m
      ) months
    ), '[]'::jsonb)
  ) into v_result;

  return v_result;
end;
$function$;

revoke execute on function public.ngombi_audience_annual_stats(integer) from anon;
grant execute on function public.ngombi_audience_annual_stats(integer) to authenticated;
