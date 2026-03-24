# Global Agent Context

- `./.tmp/` is globally git-ignored (see `~/.config/git/ignore`) and serves as a development scratch space.
- If asked to create an implementation plan, create it as `./.tmp/todo.md` — a todo markdown file that can be tracked and updated as needed.
- Long-running commands should be run in a background tmux session (e.g. `tmux new-session -d -s <name> '<cmd>'`). Progress can be monitored by polling with `tmux capture-pane -pt <name>` periodically.
