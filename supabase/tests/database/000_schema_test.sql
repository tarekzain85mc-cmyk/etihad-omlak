begin;

create extension if not exists pgtap with schema extensions;

select plan(30);

select has_schema('private', 'private schema exists');
select has_type('public', 'building_role', 'building_role enum exists');
select has_type('public', 'app_permission', 'app_permission enum exists');
select has_type('public', 'membership_status', 'membership_status enum exists');
select has_type('public', 'occupancy_kind', 'occupancy_kind enum exists');

select has_table('public', 'profiles', 'profiles table exists');
select has_table('public', 'buildings', 'buildings table exists');
select has_table('public', 'units', 'units table exists');
select has_table(
  'public',
  'building_memberships',
  'building_memberships table exists'
);
select has_table(
  'public',
  'building_membership_roles',
  'building_membership_roles table exists'
);
select has_table(
  'public',
  'unit_occupancies',
  'unit_occupancies table exists'
);
select has_table(
  'public',
  'building_invitations',
  'building_invitations table exists'
);
select has_table('public', 'audit_events', 'audit_events table exists');
select has_table(
  'private',
  'role_permissions',
  'private role_permissions table exists'
);

select ok(
  (select relrowsecurity from pg_class
    where oid = 'public.profiles'::regclass),
  'profiles has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class
    where oid = 'public.buildings'::regclass),
  'buildings has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class
    where oid = 'public.units'::regclass),
  'units has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class
    where oid = 'public.building_memberships'::regclass),
  'building_memberships has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class
    where oid = 'public.building_membership_roles'::regclass),
  'building_membership_roles has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class
    where oid = 'public.unit_occupancies'::regclass),
  'unit_occupancies has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class
    where oid = 'public.building_invitations'::regclass),
  'building_invitations has RLS enabled'
);
select ok(
  (select relrowsecurity from pg_class
    where oid = 'public.audit_events'::regclass),
  'audit_events has RLS enabled'
);

select ok(
  not exists (
    select 1
    from (
      values
        ('private.is_building_member(uuid)'::regprocedure),
        (
          'private.has_permission(uuid,public.app_permission)'
            ::regprocedure
        ),
        ('private.is_own_membership(uuid)'::regprocedure),
        ('private.can_view_membership(uuid)'::regprocedure),
        ('private.can_view_profile(uuid)'::regprocedure),
        ('private.handle_new_auth_user()'::regprocedure),
        ('private.ensure_active_building_leader()'::regprocedure)
    ) as expected(procedure_oid)
    join pg_proc as procedure on procedure.oid = expected.procedure_oid
    where not procedure.prosecdef
  ),
  'all authorization and privileged trigger functions are security definer'
);

select ok(
  not exists (
    select 1
    from (
      values
        ('private.is_building_member(uuid)'::regprocedure),
        (
          'private.has_permission(uuid,public.app_permission)'
            ::regprocedure
        ),
        ('private.is_own_membership(uuid)'::regprocedure),
        ('private.can_view_membership(uuid)'::regprocedure),
        ('private.can_view_profile(uuid)'::regprocedure),
        ('private.set_updated_at()'::regprocedure),
        ('private.handle_new_auth_user()'::regprocedure),
        ('private.ensure_active_building_leader()'::regprocedure)
    ) as expected(procedure_oid)
    join pg_proc as procedure on procedure.oid = expected.procedure_oid
    where coalesce(array_to_string(procedure.proconfig, ','), '')
      <> 'search_path=""'
  ),
  'all private functions set an exactly empty search_path'
);

select ok(
  not exists (
    select 1
    from pg_proc as procedure
    cross join lateral aclexplode(
      coalesce(
        procedure.proacl,
        acldefault('f', procedure.proowner)
      )
    ) as privilege
    where procedure.oid in (
      'private.is_building_member(uuid)'::regprocedure,
      'private.has_permission(uuid,public.app_permission)'::regprocedure,
      'private.is_own_membership(uuid)'::regprocedure,
      'private.can_view_membership(uuid)'::regprocedure,
      'private.can_view_profile(uuid)'::regprocedure,
      'private.set_updated_at()'::regprocedure,
      'private.handle_new_auth_user()'::regprocedure,
      'private.ensure_active_building_leader()'::regprocedure
    )
      and privilege.grantee in (
        0,
        (select oid from pg_roles where rolname = 'anon')
      )
      and privilege.privilege_type = 'EXECUTE'
  ),
  'public and anon cannot execute private functions'
);

select ok(
  (
    select count(*) = 5
    from (
      values
        ('private.is_building_member(uuid)'::regprocedure),
        (
          'private.has_permission(uuid,public.app_permission)'
            ::regprocedure
        ),
        ('private.is_own_membership(uuid)'::regprocedure),
        ('private.can_view_membership(uuid)'::regprocedure),
        ('private.can_view_profile(uuid)'::regprocedure)
    ) as helper(procedure_oid)
    where has_function_privilege(
      'authenticated',
      helper.procedure_oid::oid,
      'EXECUTE'
    )
  ),
  'authenticated can execute exactly the five RLS helpers'
);

select ok(
  not exists (
    select 1
    from (
      values
        ('private.set_updated_at()'::regprocedure),
        ('private.handle_new_auth_user()'::regprocedure),
        ('private.ensure_active_building_leader()'::regprocedure)
    ) as trigger_function(procedure_oid)
    where has_function_privilege(
      'authenticated',
      trigger_function.procedure_oid::oid,
      'EXECUTE'
    )
  ),
  'authenticated cannot execute trigger functions directly'
);

select ok(
  not has_sequence_privilege(
    'authenticated',
    'public.audit_events_id_seq',
    'USAGE'
  )
  and not has_sequence_privilege(
    'authenticated',
    'public.audit_events_id_seq',
    'SELECT'
  )
  and not has_sequence_privilege(
    'authenticated',
    'public.audit_events_id_seq',
    'UPDATE'
  )
  and not has_sequence_privilege(
    'anon',
    'public.audit_events_id_seq',
    'USAGE'
  )
  and not has_sequence_privilege(
    'anon',
    'public.audit_events_id_seq',
    'SELECT'
  )
  and not has_sequence_privilege(
    'anon',
    'public.audit_events_id_seq',
    'UPDATE'
  ),
  'client roles have no audit sequence privileges'
);

select ok(
  not has_column_privilege(
    'authenticated',
    'public.building_invitations',
    'token_digest',
    'SELECT'
  ),
  'authenticated cannot read invitation token digests'
);

select ok(
  has_column_privilege(
    'authenticated',
    'public.building_invitations',
    'id',
    'SELECT'
  ),
  'authenticated can read allowed invitation columns through RLS'
);

select * from finish();
rollback;
