# dotfiles

## Install vim plugins (using vim-plug)

* Create (neo)vim config directories and files:
```
cp -rv .vim* ~/
mv ~/.vim/pack ~/.vim/pack_old
mkdir -vp ~/.local/share/nvim ~/.config/nvim
ln -vs ~/.vim ~/.local/share/nvim/site
ln -vs ~/.vimrc ~/.config/nvim/init.vim
```

* Then:

> Reload the file or restart Vim, then you can,

>    :PlugInstall to install the plugins
>    :PlugUpdate to install or update the plugins
>    :PlugDiff to review the changes from the last update
>    :PlugClean to remove plugins no longer in the list

See: https://github.com/junegunn/vim-plug

Also see `.vimrc` for more info.

## Pi agent settings (`.pi/agent/`)

Config for the [pi coding agent](https://github.com/mariozechner/pi-coding-agent) lives in `.pi/agent/`.

To set up, copy or symlink into place:

```bash
mkdir -p ~/.pi/agent/extensions/plan-mode
cp .pi/agent/AGENTS.md ~/.pi/agent/AGENTS.md
cp .pi/agent/settings.json ~/.pi/agent/settings.json
cp .pi/agent/extensions/modes.ts ~/.pi/agent/extensions/modes.ts
cp .pi/agent/extensions/plan-mode/utils.ts ~/.pi/agent/extensions/plan-mode/utils.ts
cp .pi/agent/extensions/plan-mode/index.ts.disabled ~/.pi/agent/extensions/plan-mode/index.ts.disabled
```

Not tracked: `auth.json`, `bin/`, `sessions/`.

## Install vim plugins old way (using git submodules)
* Comment out vim-plug lines in `.vimrc`
* Run: git submodule update --init --recursive
* To update plugins: git submodule update --recursive --remote
* To add plugins:
  * Add as git submodule: git submodule add <https://git/repo/<name-of-plugin.git> .vim/pack/plugins/start/<name-of-plugin>
  * Commit changes: git add .gitmodules .vim/pack/plugins/start/<name-of-plugin> && ...
