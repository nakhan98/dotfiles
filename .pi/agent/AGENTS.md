# Global Agent Context

## Modes (plan/build) + Permission System

This setup uses **two extensions working together**:

### Plan/Build Mode (`extensions/modes.ts`)
Provides read-only plan mode and full-access build mode:
- Sessions always start in **plan mode** — only `read`, `grep`, `find`, `ls`, and `web_search` are available to the LLM
- Use `/build` to switch to build mode — the LLM has access to all tools (`bash`, `write`, `edit`, etc.)
- Use `/plan` to switch back to plan mode
- The current mode is shown in the footer: `mode: plan` (muted) or `mode: build` (green)
- If the `DEV_CONTAINER` environment variable is set to `1`, the footer is prefixed with `[DEV_CONTAINER]`
- One-shot mode change: `/build [msg]` or `/plan [msg]` switches mode, sends your message, then returns to the previous mode

### Permission System (`@gotgenes/pi-permission-system`)
Provides granular allow/ask/deny gates in build mode:
- `read`, `grep`, `find`, `ls` — allowed silently
- `write`, `edit` — ask for confirmation
- `web_search` — ask for confirmation
- `bash` — ask for confirmation (dangerous patterns like `rm -rf *`, `chown`, `dd`, `mkfs`, `mount` are denied outright)
- Path protection: `.env`, `~/.ssh/*`, credential files, secret files are blocked across all tools
- External directory access (outside current working directory) — ask for confirmation

<!--
  Permission prompt display note:
  When the permission system prompts "tool 'write' (matched '*')", the '(matched '*')'
  refers to the default catch-all wildcard "*": "ask" in config.json. This is the first
  rule checked and matches all tools. Since explicit tool rules like "write": "ask"
  have the same value as the wildcard, the system reports the broader '*' match in the
  prompt. This is cosmetic only — the effective behavior is identical. Tools that
  override the wildcard (e.g. "read": "allow" differs from "*": "ask") work silently
  and show no prompt at all.
-->

### How they interact
- In **plan mode**: the permission system's path protections still apply, but write/edit/bash tools aren't even visible to the LLM
- In **build mode**: all tools are visible, and the permission system enforces its allow/ask/deny rules

For multi-step tasks:
- Always explore and plan first in the conversation before making changes
- Track progress using an internal todo in conversational context/history
- Do **not** create a todo file unless the user explicitly asks for one

## Web Search

Web search is available via the `web_search` extension tool, backed by `ddgs` through `uv tool run`.
This provides first-class search and URL extraction without requiring general `bash` access.
`uv` caches ddgs after the first run so subsequent searches are near-instant.

The legacy `ddgs` skill is still present for manual use, but automatic model invocation is disabled.

### Full Page Content Retrieval

The `web_search` tool truncates output at 50KB, which may cut off large pages
(e.g., HN threads with 100+ comments). To retrieve the full content:

1. Ask the user to switch to **build mode** (`/build`)
2. Run: `uv run --with ddgs ddgs extract -u <URL>`
3. The full output is saved to `/tmp/pi-bash-*.log` by the bash tool
4. Use `read` with `offset` to page through the saved file

Note: `ddgs` is not installed as a persistent uv tool — it's invoked ephemerally
via `uv run --with ddgs`. The first run may be slow while uv caches it.

## Extending Capabilities via `uv run --with`

Beyond web search, many other tasks can be handled ephemerally using `uv run --with <package>`
to execute a one-shot Python script. This avoids permanent installations and keeps the environment clean.

Use this pattern when a task requires a specialized library not available in the default environment.
Prefer **reputable, well-maintained, and dependable libraries** — check package downloads,
maintenance status, and documentation before choosing one.

### Common use cases

- **PDF extraction**: `uv run --with pdfplumber python -c "import pdfplumber; ..."`
- **CSV/Excel processing**: `uv run --with openpyxl python -c "..."`
- **Image manipulation**: `uv run --with Pillow python -c "..."`
- **Archive extraction**: Built-in `tarfile`/`zipfile` for standard formats
- **Data serialization**: `uv run --with pyyaml`

Follow the same bash confirmation flow as any other command in build mode.

## General Guidelines

- `./.tmp/` is globally git-ignored (see `~/.config/git/ignore`) and serves as a development scratch space when working inside git repositories.
- Long-running commands should be run in a background tmux session (e.g. `tmux new-session -d -s <name> '<cmd>'`). Progress can be monitored by polling with `tmux capture-pane -pt <name>` periodically.
- For creating git branches and commit messages use the Conventional Commits standard.
