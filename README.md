# dotfiles
## Install vim plugins
* Run: git submodule update --init --recursive
* To update plugins: git submodule update --recursive --remote
* To add plugins:
  * Add as git submodule: git submodule add <https://git/repo/<name-of-plugin.git> .vim/pack/plugins/start/<name-of-plugin>
  * Commit changes: git add .gitmodules .vim/pack/plugins/start/<name-of-plugin> && ...
