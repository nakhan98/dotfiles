# Global Agent Context

## Modes (plan/build)

This setup uses a **modes extension** that controls tool access per session:

- Sessions always start in **plan mode** — read-only local tools plus `web_search` (`read`, `grep`, `find`, `ls`, `web_search`)
- Use `/build` to switch to build mode — full access (`read`, `grep`, `find`, `ls`, `web_search`, `bash`, `write`, `edit`)
- Use `/plan` to switch back to plan mode
- The current mode is shown in the footer as:
  - `mode: plan [web_search: ask|ok]`
  - `mode: build [bash: ask|ok, write: ask|ok, edit: ask|ok, web_search: ask|ok]`
- If the `DEV_CONTAINER` environment variable is set to `1`, the footer is prefixed with `[DEV_CONTAINER]`, e.g. `[DEV_CONTAINER] mode: plan [web_search: ask|ok]`
- `web_search` requires user confirmation in **both** plan and build mode unless previously accepted for the session
- In build mode, each `bash`, `write`, and `edit` call also requires user confirmation
- The confirmation dialog offers:
  - `Proceed` — allow once
  - `Accept all` — silence that tool for the rest of the session
  - `Block` — cancel the call
- Do not retry a blocked call unless the user asks you to

For multi-step tasks:
- Always explore and plan first in **plan mode**
- In **plan mode**, remain strictly read-only and keep any plan/todo in conversational context/history
- For multi-step tasks, track progress using an internal todo in conversational context/history
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
