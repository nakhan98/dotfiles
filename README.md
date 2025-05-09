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

## Install vim plugins old way (using git submodules)
* Comment out vim-plug lines in `.vimrc`
* Run: git submodule update --init --recursive
* To update plugins: git submodule update --recursive --remote
* To add plugins:
  * Add as git submodule: git submodule add <https://git/repo/<name-of-plugin.git> .vim/pack/plugins/start/<name-of-plugin>
  * Commit changes: git add .gitmodules .vim/pack/plugins/start/<name-of-plugin> && ...
