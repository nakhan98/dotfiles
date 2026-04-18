# dotfiles

## Vim setup

Copy `.vimrc` into place:

```bash
cp .vimrc ~/
```

Install [vim-plug](https://github.com/junegunn/vim-plug) if not already installed, then open Vim and run:

```
:PlugInstall
```

Useful vim-plug commands:
- `:PlugInstall` — install plugins
- `:PlugUpdate` — install or update plugins
- `:PlugDiff` — review changes from last update
- `:PlugClean` — remove plugins no longer in the list

---

## Neovim setup

Symlink the config into place:

```bash
mkdir -p ~/.config/nvim
ln -sf ~/dotfiles/.config/nvim/init.lua ~/.config/nvim/init.lua
```

[lazy.nvim](https://github.com/folke/lazy.nvim) will bootstrap itself automatically on first launch. Then open Neovim and run:

```
:Lazy sync
```

### External tool dependencies

Install Python tools via [uv](https://github.com/astral-sh/uv):

```bash
uv tool install pyright   # LSP
uv tool install ruff      # formatting + linting
```

Useful lazy.nvim commands:
- `:Lazy sync` — install and update plugins
- `:Lazy update` — update plugins
- `:Lazy clean` — remove unused plugins
- `:Lazy health` — check plugin health

---

## Pi agent settings (`.pi/agent/`)

Config for the [pi coding agent](https://github.com/mariozechner/pi-coding-agent) lives in `.pi/agent/`.

To set up, copy or symlink into place:

```bash
mkdir -p ~/.pi/agent/extensions
cp .pi/agent/AGENTS.md ~/.pi/agent/AGENTS.md
cp .pi/agent/settings.json ~/.pi/agent/settings.json
cp .pi/agent/keybindings.json ~/.pi/agent/keybindings.json
cp .pi/agent/extensions/modes.ts ~/.pi/agent/extensions/modes.ts
```

Not tracked: `auth.json`, `bin/`, `sessions/`.
