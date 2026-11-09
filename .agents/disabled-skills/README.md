# Disabled skills

Content below this directory is intentionally outside Antigravity's automatic
skill discovery path. `strix-active/` preserves the upstream Strix skills for
auditability, but their active exploitation and managed-upload workflows are
not enabled for this project.

Do not move a skill back into `.agents/skills` without a fresh, explicit owner
approval that defines the target, scope, environment, and permitted data. A
managed upload requires a separate approval.

The root `skills-lock.json` intentionally excludes all `usestrix/strix`
entries, so `npx skills update -p -y` and
`npx skills experimental_install` cannot restore them automatically. Original
source paths and hashes remain recorded in
`strix-active/upstream-lock.json`, which is documentation only and is not a
recognized active CLI lockfile.
