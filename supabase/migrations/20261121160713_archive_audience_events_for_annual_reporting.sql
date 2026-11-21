create or replace function public.ngombi_archive_audience_event()
returns trigger
language plpgsql
set search_path = ''
as $function$
begin
  insert into public.ngombi_audience_usage_daily
    (installation_id, usage_date, section, active_seconds, data_bytes)
  values
    (new.installation_id,
     (new.occurred_at at time zone 'Africa/Libreville')::date,
     new.section,
     0,
     0)
  on conflict (installation_id, usage_date, section) do nothing;

  return new;
end;
$function$;

insert into public.ngombi_audience_usage_daily
  (installation_id, usage_date, section, active_seconds, data_bytes)
select distinct
  installation_id,
  (occurred_at at time zone 'Africa/Libreville')::date,
  section,
  0,
  0
from public.ngombi_audience_events
on conflict (installation_id, usage_date, section) do nothing;

drop trigger if exists ngombi_archive_audience_event_trigger
  on public.ngombi_audience_events;

create trigger ngombi_archive_audience_event_trigger
after insert on public.ngombi_audience_events
for each row
execute function public.ngombi_archive_audience_event();
