-- NGOMBI GLOBAL / Phase 1
-- Restrict write access to NGOMBI advertising assets to verified administrators.
-- Public reads remain enabled for the public advertisements bucket so playback
-- continues to work for existing users.

begin;

-- The admin login signs in before calling this RPC. Anonymous callers do not
-- need to test arbitrary UUIDs against the administrator list.
revoke execute on function public.is_ngombi_admin(uuid) from anon;
grant execute on function public.is_ngombi_admin(uuid) to authenticated;

-- Test bucket: keep its current read behavior, but restrict uploads.
drop policy if exists "NGOMBI Test pub upload" on storage.objects;
create policy "NGOMBI Test pub admin upload"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'Test pub NGOMBI'
  and public.is_ngombi_admin(auth.uid())
);

-- Production advertising bucket: public SELECT is intentionally preserved.
drop policy if exists "NGOMBI advertisements authenticated upload v2" on storage.objects;
create policy "NGOMBI advertisements admin upload"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'advertisements'
  and public.is_ngombi_admin(auth.uid())
);

drop policy if exists "NGOMBI allow authenticated updates" on storage.objects;
create policy "NGOMBI advertisements admin update"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'advertisements'
  and public.is_ngombi_admin(auth.uid())
)
with check (
  bucket_id = 'advertisements'
  and public.is_ngombi_admin(auth.uid())
);

drop policy if exists "NGOMBI allow authenticated deletes" on storage.objects;
create policy "NGOMBI advertisements admin delete"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'advertisements'
  and public.is_ngombi_admin(auth.uid())
);

commit;
