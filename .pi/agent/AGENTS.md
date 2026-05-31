# Global Agent Context

**Note:** The `modes` extension (`extensions/modes.ts`) is currently **disabled** (renamed to `modes.ts.disabled`) while testing `@gotgenes/pi-permission-system`. There is no plan/build mode separation — all tools are available. The tool confirmation gate (bash/write/edit/web_search prompts) is also inactive. The permission system provides a more targeted permission system for file protection, dangerous commands, and path access.

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
