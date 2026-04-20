# Global Agent Context

## Modes (plan/build)

This setup uses a **modes extension** that controls tool access per session:

- Sessions always start in **plan mode** — read-only local tools plus `web_search` (`read`, `grep`, `find`, `ls`, `web_search`)
- Use `/build` to switch to build mode — full access (`read`, `grep`, `find`, `ls`, `web_search`, `bash`, `write`, `edit`)
- Use `/plan` to switch back to plan mode
- The current mode is shown in the footer as:
  - `mode: plan [web_search: ask|ok]`
  - `mode: build [bash: ask|ok, write: ask|ok, edit: ask|ok, web_search: ask|ok]`
- `web_search` requires user confirmation in **both** plan and build mode unless previously accepted for the session
- In build mode, each `bash`, `write`, and `edit` call also requires user confirmation
- The confirmation dialog offers:
  - `Proceed` — allow once
  - `Accept all` — silence that tool for the rest of the session
  - `Block` — cancel the call
- **Exception:** updates to `.tmp/todo.md` are auto-allowed for plan tracking
- Do not retry a blocked call unless the user asks you to

For multi-step tasks: explore and plan first in plan mode, then when the user switches to `/build` (or `/run`), create a `.tmp/todo.md` with the implementation plan before proceeding. Update it as steps are completed.

## Web Search

Web search is available via the `web_search` extension tool, backed by `ddgs` through `uv tool run`.
This provides first-class search and URL extraction without requiring general `bash` access.
`uv` caches ddgs after the first run so subsequent searches are near-instant.

The legacy `ddgs` skill is still present for manual use, but automatic model invocation is disabled.

## General Guidelines

- `./.tmp/` is globally git-ignored (see `~/.config/git/ignore`) and serves as a development scratch space when working inside git repositories.
- If asked to create an implementation plan or todo:
  - in a git repository, create it as `./.tmp/todo.md` — a todo markdown file that can be tracked and updated as needed
  - outside a git repository, keep the todo in conversational memory unless the user explicitly asks for a file
- Long-running commands should be run in a background tmux session (e.g. `tmux new-session -d -s <name> '<cmd>'`). Progress can be monitored by polling with `tmux capture-pane -pt <name>` periodically.
- For creating git branches and commit messages use the Conventional Commits standard.
