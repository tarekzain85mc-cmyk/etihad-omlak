begin;

create extension if not exists pgtap with schema extensions;

-- One account is president in A and resident in B. Its B role must not
-- inherit any of the member-management privileges it holds in A.
select plan(18);

insert into auth.users (id, email, raw_user_meta_data) values
  (
    'c0000000-0000-0000-0000-000000000001',
    'shared-member@example.test',
    '{"display_name":"Shared Member"}'::jsonb
  ),
  (
    'c0000000-0000-0000-0000-000000000002',
    'resident-a@example.test',
    '{"display_name":"Resident A"}'::jsonb
  ),
  (
    'c0000000-0000-0000-0000-000000000003',
    'admin-b@example.test',
    '{"display_name":"Admin B"}'::jsonb
  ),
  (
    'c0000000-0000-0000-0000-000000000004',
    'resident-b@example.test',
    '{"display_name":"Resident B"}'::jsonb
  );

insert into public.buildings (id, name, created_by) values
  (
    'c1000000-0000-0000-0000-000000000001',
    'Building A',
    'c0000000-0000-0000-0000-000000000001'
  ),
  (
    'd1000000-0000-0000-0000-000000000001',
    'Building B',
    'c0000000-0000-0000-0000-000000000003'
  );

insert into public.units (id, building_id, unit_number) values
  (
    'c2000000-0000-0000-0000-000000000001',
    'c1000000-0000-0000-0000-000000000001',
    'A-1'
  ),
  (
    'd2000000-0000-0000-0000-000000000001',
    'd1000000-0000-0000-0000-000000000001',
    'B-1'
  );

insert into public.building_memberships (
  id, building_id, user_id, created_by
) values
  (
    'c3000000-0000-0000-0000-000000000001',
    'c1000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000001'
  ),
  (
    'c3000000-0000-0000-0000-000000000002',
    'c1000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000002',
    'c0000000-0000-0000-0000-000000000001'
  ),
  (
    'd3000000-0000-0000-0000-000000000001',
    'd1000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000003'
  ),
  (
    'd3000000-0000-0000-0000-000000000002',
    'd1000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000003',
    'c0000000-0000-0000-0000-000000000003'
  ),
  (
    'd3000000-0000-0000-0000-000000000003',
    'd1000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000004',
    'c0000000-0000-0000-0000-000000000003'
  );

insert into public.building_membership_roles (
  membership_id, role, granted_by
) values
  (
    'c3000000-0000-0000-0000-000000000001',
    'president',
    'c0000000-0000-0000-0000-000000000001'
  ),
  (
    'c3000000-0000-0000-0000-000000000002',
    'resident',
    'c0000000-0000-0000-0000-000000000001'
  ),
  (
    'd3000000-0000-0000-0000-000000000001',
    'resident',
    'c0000000-0000-0000-0000-000000000003'
  ),
  (
    'd3000000-0000-0000-0000-000000000002',
    'admin',
    'c0000000-0000-0000-0000-000000000003'
  ),
  (
    'd3000000-0000-0000-0000-000000000003',
    'resident',
    'c0000000-0000-0000-0000-000000000003'
  );

insert into public.unit_occupancies (
  id, building_id, unit_id, membership_id
) values
  (
    'c4000000-0000-0000-0000-000000000001',
    'c1000000-0000-0000-0000-000000000001',
    'c2000000-0000-0000-0000-000000000001',
    'c3000000-0000-0000-0000-000000000001'
  ),
  (
    'c4000000-0000-0000-0000-000000000002',
    'c1000000-0000-0000-0000-000000000001',
    'c2000000-0000-0000-0000-000000000001',
    'c3000000-0000-0000-0000-000000000002'
  ),
  (
    'd4000000-0000-0000-0000-000000000001',
    'd1000000-0000-0000-0000-000000000001',
    'd2000000-0000-0000-0000-000000000001',
    'd3000000-0000-0000-0000-000000000001'
  ),
  (
    'd4000000-0000-0000-0000-000000000002',
    'd1000000-0000-0000-0000-000000000001',
    'd2000000-0000-0000-0000-000000000001',
    'd3000000-0000-0000-0000-000000000002'
  ),
  (
    'd4000000-0000-0000-0000-000000000003',
    'd1000000-0000-0000-0000-000000000001',
    'd2000000-0000-0000-0000-000000000001',
    'd3000000-0000-0000-0000-000000000003'
  );

insert into public.building_invitations (
  id, building_id, unit_id, target_email, token_digest,
  created_by, expires_at
) values
  (
    'c5000000-0000-0000-0000-000000000001',
    'c1000000-0000-0000-0000-000000000001',
    'c2000000-0000-0000-0000-000000000001',
    'invite-a@example.test',
    decode(repeat('cc', 32), 'hex'),
    'c0000000-0000-0000-0000-000000000001',
    now() + interval '1 day'
  ),
  (
    'd5000000-0000-0000-0000-000000000001',
    'd1000000-0000-0000-0000-000000000001',
    'd2000000-0000-0000-0000-000000000001',
    'invite-b@example.test',
    decode(repeat('dd', 32), 'hex'),
    'c0000000-0000-0000-0000-000000000003',
    now() + interval '1 day'
  );

insert into public.audit_events (
  building_id, actor_user_id, action, entity_type
) values
  (
    'c1000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000001',
    'fixture.created',
    'building'
  ),
  (
    'd1000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000003',
    'fixture.created',
    'building'
  );

set constraints all immediate;
set local role authenticated;
select set_config(
  'request.jwt.claim.sub',
  'c0000000-0000-0000-0000-000000000001',
  true
);

select results_eq(
  $$ select id from public.buildings order by id $$,
  array[
    'c1000000-0000-0000-0000-000000000001'::uuid,
    'd1000000-0000-0000-0000-000000000001'::uuid
  ],
  'shared member sees both buildings'
);
select results_eq(
  $$
    select id from public.units
    where building_id = 'c1000000-0000-0000-0000-000000000001'
  $$,
  array['c2000000-0000-0000-0000-000000000001'::uuid],
  'president sees units in A'
);
select results_eq(
  $$
    select id from public.units
    where building_id = 'd1000000-0000-0000-0000-000000000001'
  $$,
  array['d2000000-0000-0000-0000-000000000001'::uuid],
  'resident sees units in B'
);
select results_eq(
  $$ select user_id from public.profiles order by user_id $$,
  array[
    'c0000000-0000-0000-0000-000000000001'::uuid,
    'c0000000-0000-0000-0000-000000000002'::uuid
  ],
  'president sees A profiles but no other B profiles'
);
select results_eq(
  $$
    select id from public.building_memberships
    where building_id = 'c1000000-0000-0000-0000-000000000001'
    order by id
  $$,
  array[
    'c3000000-0000-0000-0000-000000000001'::uuid,
    'c3000000-0000-0000-0000-000000000002'::uuid
  ],
  'president sees all memberships in A'
);
select results_eq(
  $$
    select id from public.building_memberships
    where building_id = 'd1000000-0000-0000-0000-000000000001'
    order by id
  $$,
  array['d3000000-0000-0000-0000-000000000001'::uuid],
  'resident sees only their own membership in B'
);
select results_eq(
  $$
    select membership_id from public.building_membership_roles
    where membership_id in (
      'c3000000-0000-0000-0000-000000000001',
      'c3000000-0000-0000-0000-000000000002'
    )
    order by membership_id
  $$,
  array[
    'c3000000-0000-0000-0000-000000000001'::uuid,
    'c3000000-0000-0000-0000-000000000002'::uuid
  ],
  'president sees all membership roles in A'
);
select results_eq(
  $$
    select membership_id from public.building_membership_roles
    where membership_id in (
      'd3000000-0000-0000-0000-000000000001',
      'd3000000-0000-0000-0000-000000000002',
      'd3000000-0000-0000-0000-000000000003'
    )
    order by membership_id
  $$,
  array['d3000000-0000-0000-0000-000000000001'::uuid],
  'resident sees only their own role in B'
);
select results_eq(
  $$
    select id from public.unit_occupancies
    where building_id = 'c1000000-0000-0000-0000-000000000001'
    order by id
  $$,
  array[
    'c4000000-0000-0000-0000-000000000001'::uuid,
    'c4000000-0000-0000-0000-000000000002'::uuid
  ],
  'president sees all occupancies in A'
);
select results_eq(
  $$
    select id from public.unit_occupancies
    where building_id = 'd1000000-0000-0000-0000-000000000001'
    order by id
  $$,
  array['d4000000-0000-0000-0000-000000000001'::uuid],
  'resident sees only their own occupancy in B'
);
select is(
  (select count(*) from public.building_invitations
    where building_id = 'c1000000-0000-0000-0000-000000000001'),
  1::bigint,
  'president sees invitations in A'
);
select is(
  (select count(*) from public.building_invitations
    where building_id = 'd1000000-0000-0000-0000-000000000001'),
  0::bigint,
  'resident cannot see invitations in B'
);
select is(
  (select count(*) from public.audit_events
    where building_id = 'c1000000-0000-0000-0000-000000000001'),
  1::bigint,
  'president sees audit events in A'
);
select is(
  (select count(*) from public.audit_events
    where building_id = 'd1000000-0000-0000-0000-000000000001'),
  0::bigint,
  'resident cannot see audit events in B'
);
select ok(
  private.has_permission(
    'c1000000-0000-0000-0000-000000000001', 'manage_roles'
  ),
  'president has manage_roles in A'
);
select ok(
  not private.has_permission(
    'd1000000-0000-0000-0000-000000000001', 'manage_roles'
  ),
  'resident does not inherit manage_roles in B'
);
select ok(
  private.has_permission(
    'c1000000-0000-0000-0000-000000000001', 'view_members'
  ),
  'president has view_members in A'
);
select ok(
  not private.has_permission(
    'd1000000-0000-0000-0000-000000000001', 'view_members'
  ),
  'resident does not inherit view_members in B'
);

reset role;
select * from finish();
rollback;
