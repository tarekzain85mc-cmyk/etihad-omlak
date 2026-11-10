begin;

create extension if not exists pgtap with schema extensions;

-- Seven roles in each of two buildings, eight tables, own and other building.
select plan(224);

create temporary table role_matrix_fixture on commit drop as
select
  building.tag,
  member.role,
  member.role_number,
  (
    building.tag || '0000000-0000-0000-0000-'
    || lpad(member.role_number::text, 12, '0')
  )::uuid as user_id,
  (
    building.tag || '3000000-0000-0000-0000-'
    || lpad(member.role_number::text, 12, '0')
  )::uuid as membership_id
from (values ('a'), ('b')) as building(tag)
cross join lateral unnest(enum_range(null::public.building_role))
  with ordinality as member(role, role_number);

insert into auth.users (id, email, raw_user_meta_data)
select
  user_id,
  role::text || '-' || tag || '@example.test',
  jsonb_build_object(
    'display_name',
    initcap(replace(role::text, '_', ' ')) || ' ' || upper(tag)
  )
from role_matrix_fixture;

insert into public.buildings (id, name, created_by)
select
  (tag || '1000000-0000-0000-0000-000000000001')::uuid,
  'Building ' || upper(tag),
  user_id
from role_matrix_fixture
where role = 'admin';

insert into public.units (id, building_id, unit_number)
select
  (tag || '2000000-0000-0000-0000-000000000001')::uuid,
  (tag || '1000000-0000-0000-0000-000000000001')::uuid,
  upper(tag) || '-1'
from role_matrix_fixture
where role = 'admin';

insert into public.building_memberships (
  id, building_id, user_id, created_by
)
select
  member.membership_id,
  (member.tag || '1000000-0000-0000-0000-000000000001')::uuid,
  member.user_id,
  leader.user_id
from role_matrix_fixture as member
join role_matrix_fixture as leader
  on leader.tag = member.tag and leader.role = 'admin';

insert into public.building_membership_roles (
  membership_id, role, granted_by
)
select member.membership_id, member.role, leader.user_id
from role_matrix_fixture as member
join role_matrix_fixture as leader
  on leader.tag = member.tag and leader.role = 'admin';

insert into public.unit_occupancies (
  id, building_id, unit_id, membership_id, kind
)
select
  (
    tag || '4000000-0000-0000-0000-'
    || lpad(role_number::text, 12, '0')
  )::uuid,
  (tag || '1000000-0000-0000-0000-000000000001')::uuid,
  (tag || '2000000-0000-0000-0000-000000000001')::uuid,
  membership_id,
  'resident'::public.occupancy_kind
from role_matrix_fixture;

insert into public.building_invitations (
  id, building_id, unit_id, target_email, token_digest,
  created_by, expires_at
)
select
  (tag || '5000000-0000-0000-0000-000000000001')::uuid,
  (tag || '1000000-0000-0000-0000-000000000001')::uuid,
  (tag || '2000000-0000-0000-0000-000000000001')::uuid,
  'invite-' || tag || '@example.test',
  decode(repeat(tag, 64), 'hex'),
  user_id,
  now() + interval '1 day'
from role_matrix_fixture
where role = 'admin';

insert into public.audit_events (
  building_id, actor_user_id, action, entity_type
)
select
  (tag || '1000000-0000-0000-0000-000000000001')::uuid,
  user_id,
  'fixture.created',
  'building'
from role_matrix_fixture
where role = 'admin';

set constraints all immediate;

create function pg_temp.assert_role_matrix(
  p_user_id uuid,
  p_tag text,
  p_role public.building_role
)
returns setof text
language plpgsql
security invoker
as $$
declare
  visibility_check record;
  observed bigint;
  other_tag text := case p_tag when 'a' then 'b' else 'a' end;
  can_view_members boolean := p_role in (
    'admin', 'president', 'finance_manager'
  );
  is_leader boolean := p_role in ('admin', 'president');
  member_rows bigint;
  leader_rows bigint;
begin
  perform set_config('request.jwt.claim.sub', p_user_id::text, true);
  member_rows := case when can_view_members then 7 else 1 end;
  leader_rows := case when is_leader then 1 else 0 end;

  for visibility_check in
    select * from (values
      ('profiles', 'user_id', member_rows),
      ('buildings', 'id', 1::bigint),
      ('units', 'building_id', 1::bigint),
      ('building_memberships', 'building_id', member_rows),
      ('building_membership_roles', 'membership_id', member_rows),
      ('unit_occupancies', 'building_id', member_rows),
      ('building_invitations', 'building_id', leader_rows),
      ('audit_events', 'building_id', leader_rows)
    ) as expected(table_name, scope_column, own_count)
  loop
    execute format(
      'select count(*) from public.%I where left(%I::text, 1) = $1',
      visibility_check.table_name,
      visibility_check.scope_column
    ) into observed using p_tag;
    return next extensions.is(
      observed,
      visibility_check.own_count,
      format('%s in building %s sees own %s rows',
        p_role, upper(p_tag), visibility_check.table_name)
    );

    execute format(
      'select count(*) from public.%I where left(%I::text, 1) = $1',
      visibility_check.table_name,
      visibility_check.scope_column
    ) into observed using other_tag;
    return next extensions.is(
      observed,
      0::bigint,
      format('%s in building %s cannot see %s rows from building %s',
        p_role, upper(p_tag), visibility_check.table_name, upper(other_tag))
    );
  end loop;
end;
$$;

set local role authenticated;

select * from pg_temp.assert_role_matrix(
  'a0000000-0000-0000-0000-000000000001', 'a', 'admin'
);
select * from pg_temp.assert_role_matrix(
  'a0000000-0000-0000-0000-000000000002', 'a', 'president'
);
select * from pg_temp.assert_role_matrix(
  'a0000000-0000-0000-0000-000000000003', 'a', 'finance_manager'
);
select * from pg_temp.assert_role_matrix(
  'a0000000-0000-0000-0000-000000000004', 'a', 'security_manager'
);
select * from pg_temp.assert_role_matrix(
  'a0000000-0000-0000-0000-000000000005', 'a', 'technical_manager'
);
select * from pg_temp.assert_role_matrix(
  'a0000000-0000-0000-0000-000000000006', 'a', 'board_member'
);
select * from pg_temp.assert_role_matrix(
  'a0000000-0000-0000-0000-000000000007', 'a', 'resident'
);
select * from pg_temp.assert_role_matrix(
  'b0000000-0000-0000-0000-000000000001', 'b', 'admin'
);
select * from pg_temp.assert_role_matrix(
  'b0000000-0000-0000-0000-000000000002', 'b', 'president'
);
select * from pg_temp.assert_role_matrix(
  'b0000000-0000-0000-0000-000000000003', 'b', 'finance_manager'
);
select * from pg_temp.assert_role_matrix(
  'b0000000-0000-0000-0000-000000000004', 'b', 'security_manager'
);
select * from pg_temp.assert_role_matrix(
  'b0000000-0000-0000-0000-000000000005', 'b', 'technical_manager'
);
select * from pg_temp.assert_role_matrix(
  'b0000000-0000-0000-0000-000000000006', 'b', 'board_member'
);
select * from pg_temp.assert_role_matrix(
  'b0000000-0000-0000-0000-000000000007', 'b', 'resident'
);

reset role;
select * from finish();
rollback;
