# dotfiles
## Install vim plugins
* Run: git submodule init && git submodule update
* To update plugins: git submodule foreach git pull origin master
* To add plugins:
  * Add as git submodule: git submodule add <https://git/repo/<name-of-plugin.git> .vim/pack/plugins/start/<name-of-plugin>
  * Commit changes: git add .gitmodules .vim/pack/plugins/start/<name-of-plugin> && ...
