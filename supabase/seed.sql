-- M0 intentionally has no resident or building seed data.
-- RLS tests create deterministic fictional rows inside transactions and roll back.
select 1;
