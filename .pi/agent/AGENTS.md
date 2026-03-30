# Global Agent Context

## Modes (plan/build)

This setup uses a **modes extension** that controls tool access per session:

- Sessions always start in **plan mode** — read-only (only `read`, `grep`, `find`, `ls`)
- Use `/build` to switch to build mode — full access (`bash`, `write`, `edit`, etc.)
- Use `/plan` to switch back to read-only
- The current mode is shown in the footer

For multi-step tasks: explore and plan first in plan mode, then when the user switches to `/build` (or `/run`), create a `.tmp/todo.md` with the implementation plan before proceeding. Update it as steps are completed.

## General Guidelines

- `./.tmp/` is globally git-ignored (see `~/.config/git/ignore`) and serves as a development scratch space.
- If asked to create an implementation plan or todo, create it as `./.tmp/todo.md` — a todo markdown file that can be tracked and updated as needed.
- Long-running commands should be run in a background tmux session (e.g. `tmux new-session -d -s <name> '<cmd>'`). Progress can be monitored by polling with `tmux capture-pane -pt <name>` periodically.
- For creating git branches and commit messages use the Conventional Commits standard.
