---
name: strix-static-review
description: Perform a repository-local, read-only security review inspired by the installed Strix checklists. Use for static source inspection, diff review, threat-model checks, and remediation advice. Never run Strix, exploit a target, contact a live endpoint, or upload source.
---

# Strix static review guard

This is the only automatically discoverable Strix-facing skill in this
repository. The upstream active Strix skills are archived outside the discovery
path at `.agents/disabled-skills/strix-active`.

## Allowed without additional approval

- Read repository source, configuration, tests, and diffs.
- Trace authorization and data-flow logic without executing an attack.
- Search for exposed secrets locally without printing secret values.
- Recommend minimal fixes and non-destructive tests.

## Prohibited without fresh, explicit approval

- Running `strix`, a pentest, an exploit, DAST, or proof-of-concept attack.
- Contacting any URL, IP, API, Supabase, Fawry, or production/staging target.
- Uploading source, findings, resident data, credentials, or artifacts.
- Restoring an upstream active Strix skill to `.agents/skills`.

Managed Strix upload always needs its own separate approval, even when a local
active test has already been approved. Record the approved target, scope,
environment, and data constraints before any active work.

## Output

Report evidence by file and line, severity, impact, and the smallest safe fix.
Clearly label anything not proven by static evidence as a hypothesis.
