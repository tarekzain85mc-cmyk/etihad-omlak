begin;

create extension if not exists pgtap with schema extensions;

select plan(34);

insert into auth.users (id, email, raw_user_meta_data) values
  (
    '10000000-0000-0000-0000-000000000001',
    'admin-a@example.test',
    '{"display_name":"Admin A"}'::jsonb
  ),
  (
    '10000000-0000-0000-0000-000000000002',
    'resident-a@example.test',
    '{"display_name":"Resident A"}'::jsonb
  ),
  (
    '20000000-0000-0000-0000-000000000001',
    'admin-b@example.test',
    '{"display_name":"Admin B"}'::jsonb
  ),
  (
    '20000000-0000-0000-0000-000000000002',
    'resident-b@example.test',
    '{"display_name":"Resident B"}'::jsonb
  );

insert into public.buildings (id, name, created_by) values
  (
    'a0000000-0000-0000-0000-000000000001',
    'Building A',
    '10000000-0000-0000-0000-000000000001'
  ),
  (
    'b0000000-0000-0000-0000-000000000001',
    'Building B',
    '20000000-0000-0000-0000-000000000001'
  );

insert into public.units (id, building_id, unit_number) values
  (
    'a1000000-0000-0000-0000-000000000001',
    'a0000000-0000-0000-0000-000000000001',
    'A-1'
  ),
  (
    'b1000000-0000-0000-0000-000000000001',
    'b0000000-0000-0000-0000-000000000001',
    'B-1'
  );

insert into public.building_memberships (
  id,
  building_id,
  user_id,
  created_by
) values
  (
    'a2000000-0000-0000-0000-000000000001',
    'a0000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001'
  ),
  (
    'a2000000-0000-0000-0000-000000000002',
    'a0000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000002',
    '10000000-0000-0000-0000-000000000001'
  ),
  (
    'b2000000-0000-0000-0000-000000000001',
    'b0000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000001'
  ),
  (
    'b2000000-0000-0000-0000-000000000002',
    'b0000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000002',
    '20000000-0000-0000-0000-000000000001'
  );

insert into public.building_membership_roles (
  membership_id,
  role,
  granted_by
) values
  (
    'a2000000-0000-0000-0000-000000000001',
    'admin',
    '10000000-0000-0000-0000-000000000001'
  ),
  (
    'a2000000-0000-0000-0000-000000000002',
    'resident',
    '10000000-0000-0000-0000-000000000001'
  ),
  (
    'b2000000-0000-0000-0000-000000000001',
    'admin',
    '20000000-0000-0000-0000-000000000001'
  ),
  (
    'b2000000-0000-0000-0000-000000000002',
    'resident',
    '20000000-0000-0000-0000-000000000001'
  );

insert into public.unit_occupancies (
  id,
  building_id,
  unit_id,
  membership_id,
  kind
) values
  (
    'a3000000-0000-0000-0000-000000000001',
    'a0000000-0000-0000-0000-000000000001',
    'a1000000-0000-0000-0000-000000000001',
    'a2000000-0000-0000-0000-000000000002',
    'resident'
  ),
  (
    'b3000000-0000-0000-0000-000000000001',
    'b0000000-0000-0000-0000-000000000001',
    'b1000000-0000-0000-0000-000000000001',
    'b2000000-0000-0000-0000-000000000002',
    'resident'
  );

insert into public.building_invitations (
  id,
  building_id,
  unit_id,
  target_email,
  target_phone_e164,
  token_digest,
  created_by,
  expires_at
) values
  (
    'a4000000-0000-0000-0000-000000000001',
    'a0000000-0000-0000-0000-000000000001',
    'a1000000-0000-0000-0000-000000000001',
    'invite-a@example.test',
    '+201234567890',
    decode(repeat('11', 32), 'hex'),
    '10000000-0000-0000-0000-000000000001',
    now() + interval '1 day'
  ),
  (
    'b4000000-0000-0000-0000-000000000001',
    'b0000000-0000-0000-0000-000000000001',
    'b1000000-0000-0000-0000-000000000001',
    'invite-b@example.test',
    null,
    decode(repeat('22', 32), 'hex'),
    '20000000-0000-0000-0000-000000000001',
    now() + interval '1 day'
  );

insert into public.audit_events (
  building_id,
  actor_user_id,
  action,
  entity_type,
  entity_id
) values
  (
    'a0000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    'membership.created',
    'building_membership',
    'a2000000-0000-0000-0000-000000000002'
  ),
  (
    'b0000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000001',
    'membership.created',
    'building_membership',
    'b2000000-0000-0000-0000-000000000002'
  );

set constraints all immediate;

select throws_ok(
  $$
    insert into public.building_invitations (
      id,
      building_id,
      unit_id,
      target_phone_e164,
      token_digest,
      created_by,
      expires_at
    ) values (
      'a4000000-0000-0000-0000-000000000010',
      'a0000000-0000-0000-0000-000000000001',
      'a1000000-0000-0000-0000-000000000001',
      chr(92) || '201234567890',
      decode(repeat('33', 32), 'hex'),
      '10000000-0000-0000-0000-000000000001',
      now() + interval '1 day'
    )
  $$,
  '23514',
  null,
  'invitation rejects a phone number beginning with backslash'
);

select throws_ok(
  $$
    insert into public.building_invitations (
      id,
      building_id,
      unit_id,
      target_email,
      token_digest,
      created_by,
      expires_at
    ) values (
      'a4000000-0000-0000-0000-000000000011',
      'a0000000-0000-0000-0000-000000000001',
      'a1000000-0000-0000-0000-000000000001',
      '',
      decode(repeat('44', 32), 'hex'),
      '10000000-0000-0000-0000-000000000001',
      now() + interval '1 day'
    )
  $$,
  '23514',
  null,
  'invitation rejects an empty email address'
);

select throws_ok(
  $$
    insert into public.building_invitations (
      id,
      building_id,
      unit_id,
      target_email,
      token_digest,
      created_by,
      accepted_by,
      accepted_at,
      expires_at
    ) values (
      'a4000000-0000-0000-0000-000000000012',
      'a0000000-0000-0000-0000-000000000001',
      'a1000000-0000-0000-0000-000000000001',
      'early@example.test',
      decode(repeat('55', 32), 'hex'),
      '10000000-0000-0000-0000-000000000001',
      '10000000-0000-0000-0000-000000000002',
      now() - interval '1 minute',
      now() + interval '1 day'
    )
  $$,
  '23514',
  null,
  'invitation rejects acceptance before creation'
);

select throws_ok(
  $$
    insert into public.building_invitations (
      id,
      building_id,
      unit_id,
      target_email,
      token_digest,
      created_by,
      revoked_at,
      expires_at
    ) values (
      'a4000000-0000-0000-0000-000000000013',
      'a0000000-0000-0000-0000-000000000001',
      'a1000000-0000-0000-0000-000000000001',
      'revoked@example.test',
      decode(repeat('66', 32), 'hex'),
      '10000000-0000-0000-0000-000000000001',
      now() - interval '1 minute',
      now() + interval '1 day'
    )
  $$,
  '23514',
  null,
  'invitation rejects revocation before creation'
);

select throws_ok(
  $$
    insert into public.building_invitations (
      id,
      building_id,
      unit_id,
      target_email,
      token_digest,
      created_by,
      expires_at
    ) values (
      'a4000000-0000-0000-0000-000000000014',
      'a0000000-0000-0000-0000-000000000001',
      'b1000000-0000-0000-0000-000000000001',
      'cross-building@example.test',
      decode(repeat('77', 32), 'hex'),
      '10000000-0000-0000-0000-000000000001',
      now() + interval '1 day'
    )
  $$,
  '23503',
  null,
  'cross-building invitation is rejected by a foreign key'
);

select throws_ok(
  $$
    delete from public.building_membership_roles
    where membership_id = 'a2000000-0000-0000-0000-000000000001'
      and role = 'admin'
  $$,
  '23514',
  'building must retain an active admin or president',
  'the only leader role cannot be removed'
);

select throws_ok(
  $$
    update public.building_memberships
    set status = 'suspended'
    where id = 'a2000000-0000-0000-0000-000000000001'
  $$,
  '23514',
  'building must retain an active admin or president',
  'the only leader membership cannot be suspended'
);

select throws_ok(
  $$
    delete from public.building_memberships
    where id = 'a2000000-0000-0000-0000-000000000001'
  $$,
  '23514',
  'building must retain an active admin or president',
  'the only leader membership cannot be deleted'
);

insert into public.building_membership_roles (
  membership_id,
  role,
  granted_by
) values (
  'a2000000-0000-0000-0000-000000000002',
  'president',
  '10000000-0000-0000-0000-000000000001'
);

select lives_ok(
  $$
    delete from public.building_membership_roles
    where membership_id = 'a2000000-0000-0000-0000-000000000001'
      and role = 'admin'
  $$,
  'a leader role can be removed when another active leader remains'
);

insert into public.building_membership_roles (
  membership_id,
  role,
  granted_by
) values (
  'a2000000-0000-0000-0000-000000000001',
  'admin',
  '10000000-0000-0000-0000-000000000001'
);
delete from public.building_membership_roles
where membership_id = 'a2000000-0000-0000-0000-000000000002'
  and role = 'president';

select throws_ok(
  $$
    insert into public.unit_occupancies (
      building_id,
      unit_id,
      membership_id,
      kind
    ) values (
      'a0000000-0000-0000-0000-000000000001',
      'a1000000-0000-0000-0000-000000000001',
      'b2000000-0000-0000-0000-000000000002',
      'resident'
    )
  $$,
  '23503',
  null,
  'cross-building occupancy is rejected by a foreign key'
);

set local role authenticated;
select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000002',
  true
);

select results_eq(
  $$ select id from public.buildings order by id $$,
  array['a0000000-0000-0000-0000-000000000001'::uuid],
  'resident sees only building A'
);
select results_eq(
  $$ select id from public.units order by id $$,
  array['a1000000-0000-0000-0000-000000000001'::uuid],
  'resident sees units only in building A'
);
select results_eq(
  $$ select id from public.building_memberships order by id $$,
  array['a2000000-0000-0000-0000-000000000002'::uuid],
  'resident sees only their own membership'
);
select results_eq(
  $$
    select role
    from public.building_membership_roles
    order by role
  $$,
  array['resident'::public.building_role],
  'resident sees only their own role'
);
select results_eq(
  $$ select id from public.unit_occupancies order by id $$,
  array['a3000000-0000-0000-0000-000000000001'::uuid],
  'resident sees only their own occupancy'
);
select is(
  (select count(*) from public.building_invitations),
  0::bigint,
  'resident cannot see invitations'
);
select is(
  (select count(*) from public.audit_events),
  0::bigint,
  'resident cannot see audit events'
);
select is(
  (
    with changed as (
      update public.profiles
      set display_name = 'Changed by self'
      where user_id = '10000000-0000-0000-0000-000000000002'
      returning 1
    )
    select count(*) from changed
  ),
  1::bigint,
  'resident can update their own profile'
);
select throws_ok(
  $$
    update public.profiles
    set display_name = ' Padded name '
    where user_id = '10000000-0000-0000-0000-000000000002'
  $$,
  '23514',
  null,
  'profile display names must be stored without surrounding whitespace'
);
select is(
  (
    with changed as (
      update public.profiles
      set display_name = 'Unauthorized change'
      where user_id = '20000000-0000-0000-0000-000000000002'
      returning 1
    )
    select count(*) from changed
  ),
  0::bigint,
  'resident cannot update another profile'
);
select throws_ok(
  $$
    insert into public.building_membership_roles (
      membership_id,
      role,
      granted_by
    ) values (
      'a2000000-0000-0000-0000-000000000002',
      'admin',
      '10000000-0000-0000-0000-000000000002'
    )
  $$,
  '42501',
  null,
  'resident cannot grant themselves a role'
);

select throws_ok(
  $$
    insert into public.building_memberships (building_id, user_id)
    values (
      'a0000000-0000-0000-0000-000000000001',
      '20000000-0000-0000-0000-000000000002'
    )
  $$,
  '42501',
  null,
  'resident cannot add a building membership directly'
);

select throws_ok(
  $$
    insert into public.building_invitations (
      building_id,
      unit_id,
      target_email,
      token_digest,
      created_by,
      expires_at
    ) values (
      'a0000000-0000-0000-0000-000000000001',
      'a1000000-0000-0000-0000-000000000001',
      'unauthorized@example.test',
      decode(repeat('88', 32), 'hex'),
      '10000000-0000-0000-0000-000000000002',
      now() + interval '1 day'
    )
  $$,
  '42501',
  null,
  'resident cannot create an invitation directly'
);

select throws_ok(
  $$
    insert into public.audit_events (
      building_id,
      actor_user_id,
      action,
      entity_type
    ) values (
      'a0000000-0000-0000-0000-000000000001',
      '10000000-0000-0000-0000-000000000002',
      'unauthorized.write',
      'audit_event'
    )
  $$,
  '42501',
  null,
  'resident cannot write an audit event directly'
);

select throws_ok(
  $$ select token_digest from public.building_invitations $$,
  '42501',
  null,
  'authenticated clients cannot read invitation token digests'
);

reset role;
set local role authenticated;
select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000001',
  true
);

select results_eq(
  $$ select id from public.buildings order by id $$,
  array['a0000000-0000-0000-0000-000000000001'::uuid],
  'admin sees only building A'
);
select results_eq(
  $$ select id from public.building_memberships order by id $$,
  array[
    'a2000000-0000-0000-0000-000000000001'::uuid,
    'a2000000-0000-0000-0000-000000000002'::uuid
  ],
  'admin sees only memberships in building A'
);
select results_eq(
  $$ select user_id from public.profiles order by user_id $$,
  array[
    '10000000-0000-0000-0000-000000000001'::uuid,
    '10000000-0000-0000-0000-000000000002'::uuid
  ],
  'admin sees profiles only for building A'
);
select results_eq(
  $$ select id from public.building_invitations order by id $$,
  array['a4000000-0000-0000-0000-000000000001'::uuid],
  'admin sees invitations only for building A'
);
select results_eq(
  $$ select building_id from public.audit_events order by id $$,
  array['a0000000-0000-0000-0000-000000000001'::uuid],
  'admin sees audit events only for building A'
);

reset role;
update public.building_memberships
set status = 'suspended'
where id = 'a2000000-0000-0000-0000-000000000002';

set local role authenticated;
select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000002',
  true
);
select is(
  (select count(*) from public.buildings),
  0::bigint,
  'suspended member loses building access'
);

reset role;
set local role authenticated;
select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000001',
  true
);
select results_eq(
  $$
    select role
    from public.building_membership_roles
    where membership_id = 'a2000000-0000-0000-0000-000000000002'
    order by role
  $$,
  array['resident'::public.building_role],
  'admin can review roles on a suspended membership'
);
select results_eq(
  $$
    select user_id
    from public.profiles
    where user_id = '10000000-0000-0000-0000-000000000002'
  $$,
  array['10000000-0000-0000-0000-000000000002'::uuid],
  'admin can review the profile of a suspended member'
);

reset role;
set local role anon;
select throws_ok(
  $$ select count(*) from public.buildings $$,
  '42501',
  null,
  'anonymous role has no table access'
);

reset role;
select * from finish();
rollback;
