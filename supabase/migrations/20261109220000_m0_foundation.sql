begin;

create extension if not exists pgcrypto with schema extensions;

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
grant usage on schema private to authenticated;

create type public.building_role as enum (
  'admin',
  'president',
  'finance_manager',
  'security_manager',
  'technical_manager',
  'board_member',
  'resident'
);

create type public.app_permission as enum (
  'view_building',
  'view_members',
  'manage_members',
  'manage_roles',
  'manage_units',
  'manage_invitations',
  'view_audit'
);

create type public.membership_status as enum (
  'active',
  'suspended',
  'revoked'
);

create type public.occupancy_kind as enum (
  'owner',
  'tenant',
  'resident'
);

create table public.profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null
    check (char_length(display_name) between 1 and 120)
    check (display_name = btrim(display_name)),
  avatar_path text
    check (
      avatar_path is null
      or (
        char_length(avatar_path) between 1 and 1024
        and avatar_path = btrim(avatar_path)
      )
    ),
  preferred_locale text not null default 'ar'
    check (preferred_locale in ('ar', 'en')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.buildings (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(btrim(name)) between 1 and 160),
  created_by uuid not null references auth.users (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.units (
  id uuid primary key default gen_random_uuid(),
  building_id uuid not null references public.buildings (id) on delete cascade,
  unit_number text not null
    check (char_length(btrim(unit_number)) between 1 and 80),
  floor_label text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (building_id, unit_number),
  unique (id, building_id)
);

create table public.building_memberships (
  id uuid primary key default gen_random_uuid(),
  building_id uuid not null references public.buildings (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete restrict,
  status public.membership_status not null default 'active',
  created_by uuid references auth.users (id) on delete set null,
  joined_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (building_id, user_id),
  unique (id, building_id)
);

create index building_memberships_user_id_idx
  on public.building_memberships (user_id);
create index building_memberships_building_status_idx
  on public.building_memberships (building_id, status);

create table public.building_membership_roles (
  membership_id uuid not null
    references public.building_memberships (id) on delete cascade,
  role public.building_role not null,
  granted_by uuid references auth.users (id) on delete set null,
  granted_at timestamptz not null default now(),
  primary key (membership_id, role)
);

create index building_membership_roles_role_idx
  on public.building_membership_roles (role, membership_id);

create table public.unit_occupancies (
  id uuid primary key default gen_random_uuid(),
  building_id uuid not null,
  unit_id uuid not null,
  membership_id uuid not null,
  kind public.occupancy_kind not null default 'resident',
  starts_at timestamptz not null default now(),
  ends_at timestamptz,
  created_at timestamptz not null default now(),
  constraint unit_occupancies_dates_check
    check (ends_at is null or ends_at > starts_at),
  constraint unit_occupancies_unit_building_fk
    foreign key (unit_id, building_id)
    references public.units (id, building_id) on delete cascade,
  constraint unit_occupancies_membership_building_fk
    foreign key (membership_id, building_id)
    references public.building_memberships (id, building_id) on delete cascade
);

create unique index unit_occupancies_active_unique_idx
  on public.unit_occupancies (unit_id, membership_id)
  where ends_at is null;
create index unit_occupancies_membership_idx
  on public.unit_occupancies (membership_id);
create index unit_occupancies_building_idx
  on public.unit_occupancies (building_id);

create table public.building_invitations (
  id uuid primary key default gen_random_uuid(),
  building_id uuid not null,
  unit_id uuid not null,
  target_email text,
  target_phone_e164 text,
  initial_role public.building_role not null default 'resident',
  token_digest bytea not null unique
    check (octet_length(token_digest) = 32),
  created_by uuid not null references auth.users (id) on delete restrict,
  accepted_by uuid references auth.users (id) on delete restrict,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null,
  accepted_at timestamptz,
  revoked_at timestamptz,
  updated_at timestamptz not null default now(),
  constraint building_invitations_unit_building_fk
    foreign key (unit_id, building_id)
    references public.units (id, building_id) on delete cascade,
  constraint building_invitations_target_check
    check (target_email is not null or target_phone_e164 is not null),
  constraint building_invitations_email_normalized_check
    check (
      target_email is null
      or (
        char_length(btrim(target_email)) between 3 and 320
        and target_email = lower(btrim(target_email))
      )
    ),
  constraint building_invitations_phone_check
    check (
      target_phone_e164 is null
      or target_phone_e164 ~ '^[+][1-9][0-9]{7,14}$'
    ),
  constraint building_invitations_expiry_check
    check (expires_at > created_at),
  constraint building_invitations_acceptance_check
    check (
      (accepted_at is null and accepted_by is null)
      or (accepted_at is not null and accepted_by is not null)
    ),
  constraint building_invitations_terminal_state_check
    check (not (accepted_at is not null and revoked_at is not null)),
  constraint building_invitations_accepted_window_check
    check (
      accepted_at is null
      or (accepted_at >= created_at and accepted_at <= expires_at)
    ),
  constraint building_invitations_revoked_time_check
    check (revoked_at is null or revoked_at >= created_at)
);

create index building_invitations_building_idx
  on public.building_invitations (building_id);
create index building_invitations_active_idx
  on public.building_invitations (building_id, expires_at)
  where accepted_at is null and revoked_at is null;

create table public.audit_events (
  id bigint generated always as identity primary key,
  building_id uuid not null references public.buildings (id) on delete restrict,
  actor_user_id uuid references auth.users (id) on delete set null,
  action text not null check (char_length(btrim(action)) between 1 and 120),
  entity_type text not null
    check (char_length(btrim(entity_type)) between 1 and 120),
  entity_id text,
  request_id uuid,
  old_data jsonb,
  new_data jsonb,
  created_at timestamptz not null default now(),
  constraint audit_events_old_data_check
    check (old_data is null or jsonb_typeof(old_data) = 'object'),
  constraint audit_events_new_data_check
    check (new_data is null or jsonb_typeof(new_data) = 'object')
);

create index audit_events_building_created_idx
  on public.audit_events (building_id, created_at desc);
create index audit_events_actor_idx
  on public.audit_events (actor_user_id)
  where actor_user_id is not null;

create table private.role_permissions (
  role public.building_role not null,
  permission public.app_permission not null,
  primary key (role, permission)
);

insert into private.role_permissions (role, permission)
select leader.role, permission.permission
from unnest(array['admin', 'president']::public.building_role[]) as leader(role)
cross join unnest(enum_range(null::public.app_permission)) as permission(permission);

insert into private.role_permissions (role, permission) values
  ('finance_manager', 'view_building'),
  ('finance_manager', 'view_members'),
  ('security_manager', 'view_building'),
  ('technical_manager', 'view_building'),
  ('board_member', 'view_building'),
  ('resident', 'view_building');

revoke all on table private.role_permissions from public, anon, authenticated;

create function private.is_building_member(p_building_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.building_memberships as membership
    where membership.building_id = p_building_id
      and membership.user_id = (select auth.uid())
      and membership.status = 'active'::public.membership_status
  );
$$;

create function private.has_permission(
  p_building_id uuid,
  p_permission public.app_permission
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.building_memberships as membership
    join public.building_membership_roles as membership_role
      on membership_role.membership_id = membership.id
    join private.role_permissions as role_permission
      on role_permission.role = membership_role.role
    where membership.building_id = p_building_id
      and membership.user_id = (select auth.uid())
      and membership.status = 'active'::public.membership_status
      and role_permission.permission = p_permission
  );
$$;

create function private.is_own_membership(p_membership_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.building_memberships as membership
    where membership.id = p_membership_id
      and membership.user_id = (select auth.uid())
      and membership.status = 'active'::public.membership_status
  );
$$;

create function private.can_view_membership(p_membership_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.building_memberships as membership
    where membership.id = p_membership_id
      and (
        (
          membership.user_id = (select auth.uid())
          and membership.status = 'active'::public.membership_status
        )
        or private.has_permission(
          membership.building_id,
          'view_members'::public.app_permission
        )
      )
  );
$$;

create function private.can_view_profile(p_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select p_user_id = (select auth.uid())
    or exists (
      select 1
      from public.building_memberships as target_membership
      join public.building_memberships as viewer_membership
        on viewer_membership.building_id = target_membership.building_id
      join public.building_membership_roles as viewer_role
        on viewer_role.membership_id = viewer_membership.id
      join private.role_permissions as role_permission
        on role_permission.role = viewer_role.role
      where target_membership.user_id = p_user_id
        and viewer_membership.user_id = (select auth.uid())
        and viewer_membership.status = 'active'::public.membership_status
        and role_permission.permission = 'view_members'::public.app_permission
    );
$$;

revoke all on function private.is_building_member(uuid) from public, anon;
revoke all on function private.has_permission(uuid, public.app_permission)
  from public, anon;
revoke all on function private.is_own_membership(uuid) from public, anon;
revoke all on function private.can_view_membership(uuid) from public, anon;
revoke all on function private.can_view_profile(uuid) from public, anon;

grant execute on function private.is_building_member(uuid) to authenticated;
grant execute on function private.has_permission(uuid, public.app_permission)
  to authenticated;
grant execute on function private.is_own_membership(uuid) to authenticated;
grant execute on function private.can_view_membership(uuid) to authenticated;
grant execute on function private.can_view_profile(uuid) to authenticated;

create function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create function private.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  resolved_display_name text;
begin
  resolved_display_name := coalesce(
    nullif(btrim(new.raw_user_meta_data ->> 'display_name'), ''),
    nullif(split_part(coalesce(new.email, ''), '@', 1), ''),
    'مستخدم'
  );

  insert into public.profiles (user_id, display_name)
  values (new.id, left(resolved_display_name, 120))
  on conflict (user_id) do nothing;

  return new;
end;
$$;

revoke all on function private.set_updated_at() from public, anon, authenticated;
revoke all on function private.handle_new_auth_user()
  from public, anon, authenticated;

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function private.set_updated_at();

create trigger buildings_set_updated_at
before update on public.buildings
for each row execute function private.set_updated_at();

create trigger units_set_updated_at
before update on public.units
for each row execute function private.set_updated_at();

create trigger memberships_set_updated_at
before update on public.building_memberships
for each row execute function private.set_updated_at();

create trigger invitations_set_updated_at
before update on public.building_invitations
for each row execute function private.set_updated_at();

create trigger on_auth_user_created
after insert on auth.users
for each row execute function private.handle_new_auth_user();

create function private.ensure_active_building_leader()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  checked_building_id uuid;
begin
  if tg_table_name = 'buildings' then
    checked_building_id := new.id;
  elsif tg_table_name = 'building_membership_roles' then
    select membership.building_id
      into checked_building_id
    from public.building_memberships as membership
    where membership.id = old.membership_id;
  else
    checked_building_id := old.building_id;
  end if;

  if checked_building_id is null
    or not exists (
      select 1
      from public.buildings as building
      where building.id = checked_building_id
    ) then
    return null;
  end if;

  if not exists (
    select 1
    from public.building_memberships as membership
    join public.building_membership_roles as membership_role
      on membership_role.membership_id = membership.id
    where membership.building_id = checked_building_id
      and membership.status = 'active'::public.membership_status
      and membership_role.role in (
        'admin'::public.building_role,
        'president'::public.building_role
      )
  ) then
    raise exception using
      errcode = '23514',
      message = 'building must retain an active admin or president';
  end if;

  return null;
end;
$$;

revoke all on function private.ensure_active_building_leader()
  from public, anon, authenticated;

create constraint trigger buildings_require_leader
after insert or update on public.buildings
deferrable initially deferred
for each row execute function private.ensure_active_building_leader();

create constraint trigger building_roles_require_leader
after delete or update on public.building_membership_roles
deferrable initially deferred
for each row execute function private.ensure_active_building_leader();

create constraint trigger memberships_require_leader
after delete or update on public.building_memberships
deferrable initially deferred
for each row execute function private.ensure_active_building_leader();

alter table public.profiles enable row level security;
alter table public.buildings enable row level security;
alter table public.units enable row level security;
alter table public.building_memberships enable row level security;
alter table public.building_membership_roles enable row level security;
alter table public.unit_occupancies enable row level security;
alter table public.building_invitations enable row level security;
alter table public.audit_events enable row level security;

create policy profiles_select_visible
on public.profiles
for select
to authenticated
using ((select private.can_view_profile(user_id)));

create policy profiles_update_self
on public.profiles
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy buildings_select_member
on public.buildings
for select
to authenticated
using ((select private.is_building_member(id)));

create policy units_select_member
on public.units
for select
to authenticated
using ((select private.is_building_member(building_id)));

create policy memberships_select_self_or_manager
on public.building_memberships
for select
to authenticated
using (
  (
    (select auth.uid()) = user_id
    and status = 'active'::public.membership_status
  )
  or (select private.has_permission(
    building_id,
    'view_members'::public.app_permission
  ))
);

create policy membership_roles_select_self_or_manager
on public.building_membership_roles
for select
to authenticated
using ((select private.can_view_membership(membership_id)));

create policy occupancies_select_self_or_manager
on public.unit_occupancies
for select
to authenticated
using (
  (select private.is_own_membership(membership_id))
  or (select private.has_permission(
    building_id,
    'view_members'::public.app_permission
  ))
);

create policy invitations_select_manager
on public.building_invitations
for select
to authenticated
using ((select private.has_permission(
  building_id,
  'manage_invitations'::public.app_permission
)));

create policy audit_events_select_privileged
on public.audit_events
for select
to authenticated
using ((select private.has_permission(
  building_id,
  'view_audit'::public.app_permission
)));

revoke all on table public.profiles from anon, authenticated;
revoke all on table public.buildings from anon, authenticated;
revoke all on table public.units from anon, authenticated;
revoke all on table public.building_memberships from anon, authenticated;
revoke all on table public.building_membership_roles from anon, authenticated;
revoke all on table public.unit_occupancies from anon, authenticated;
revoke all on table public.building_invitations from anon, authenticated;
revoke all on table public.audit_events from anon, authenticated;
revoke all on sequence public.audit_events_id_seq
  from public, anon, authenticated;

grant select on table public.profiles to authenticated;
grant update (display_name, avatar_path, preferred_locale)
  on table public.profiles to authenticated;
grant select on table public.buildings to authenticated;
grant select on table public.units to authenticated;
grant select on table public.building_memberships to authenticated;
grant select on table public.building_membership_roles to authenticated;
grant select on table public.unit_occupancies to authenticated;
grant select (
  id,
  building_id,
  unit_id,
  target_email,
  target_phone_e164,
  initial_role,
  created_by,
  accepted_by,
  created_at,
  expires_at,
  accepted_at,
  revoked_at,
  updated_at
) on table public.building_invitations to authenticated;
grant select on table public.audit_events to authenticated;

commit;
