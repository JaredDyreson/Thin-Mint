#!/usr/bin/env bash

cp -ar /home/"$USER"/Projects/dotfiles/shell/zshrc /home/"$USER"/.zshrc
#curl -fsSL https://raw.githubUSERcontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash 
git clone https://github.com/zsh-USERs/zsh-syntax-highlighting.git
# echo "source ${(q-)PWD}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
pacman -Sy --noconfirm vim cmake
yay -Sy --noconfirm vundle
vim +silent +PluginInstall +qall
pacman -Sy --noconfirm rxvt-unicode xorg-xrdb ttf-dejavu powerline powerline-fontsa
pacman -Sy --noconfirm clang most jre-openjdk jdk-openjdk openjdk-doc python-pip texlive-most pandoc pdfgrep wget
