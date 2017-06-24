# Prerequisites
You will need to install brew, hyper, neovim, and tmux

## macOS


```bash
brew install git
brew install tig
brew install tmux
brew install python
brew install python3
brew install ruby
brew install reattach-to-user-namespace
brew install neovim/neovim/neovim
brew install node
pip install neovim
pip3 install neovim
gem install neovim
```

Clone folder in home directory.

```bash
git clone https://github.com/berkeleytrue/dotfiles.git ~/.vim
```


While in your home directory enter the following,

```bash
curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim;
rm ~/.profile
ln -s ~/.vim/dotfiles/czrc.json ~/.czrc
ln -s ~/.vim/dotfiles/profile ~/.profile
ln -s ~/.vim/dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/.vim/dotfiles/eslintrc ~/.eslintrc
ln -s ~/.vim/dotfiles/vintrc.yml ~/.vintrc.yml
ln -s ~/.vim/dotfiles/hyper.js ~/.hyper.js
ln -s ~/.vim/dotfiles/init.vim ~/.config/nvim/init.vim
ln -s ~/.vim/dotfiles/modules ~/.config/nvim/modules
ln -s ~/.vim/spell ~/.config/nvim/spell
source ~/.profile
```

Now install global npm packages required for git workflow and npm publishing
```bash
npmpublishpre
```

This will create symbolic links in the home dir and the config
directory.

Now open up neovim and run the plugin installer, this should take a while.

```
nvim
```

And the run the following commands one after the other

```
:PlugInstall
:UpdateRemotePlugins
```

Now [install hyper](https://hyper.is/)

Install [patched nerd fonts](https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20for%20Powerline%20Nerd%20Font%20Complete%20Mono.otf)
