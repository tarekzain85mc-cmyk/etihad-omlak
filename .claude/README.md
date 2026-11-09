# Claude project integration

- Project skills in `.claude/skills` are lightweight wrappers over the canonical copies in `.agents/skills`.
- Context7 is configured in the root `.mcp.json`; Claude still requires the normal workspace-trust and project-MCP approval steps.
- 21st is intentionally omitted until an API key is supplied outside version control.
- Active Strix workflows stay quarantined; only `strix-static-review` is discoverable.

