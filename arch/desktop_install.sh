#!/usr/bin/env bash

# this is important if you want to install packages after you install (DUH!)

function make_root() {
	[[ "$(whoami)" != "root" ]] && (echo "Run as root!";exit)
	echo "$1 ALL=(ALL) ALL"  >> /etc/sudoers
}

# install yay first

sudo pacman -Sy --noconfirm git

git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay

# Make it look like Linux Mint

cd /tmp && mkdir build && cd build

git clone https://aur.archlinux.org/mint-x-icons.git
git clone https://aur.archlinux.org/mint-y-icons.git
git clone https://aur.archlinux.org/mint-themes.git

cd mint-x-icons && makepkg -si --noconfirm 
cd ../mint-y-icons && makepkg -si --noconfirm
cd ../mint-themes && makepkg -si --noconfirm

sudo rm -rf mint* && cd ..

# Install the Display Manager and theme

sudo pacman -Sy --noconfirm lightdm lightdm-gtk-greeter
git clone https://aur.archlinux.org/lightdm-slick-greeter.git
cd lightdm-slick-greeter && makepkg -si --noconfirm
cd ..
systemctl enable lightdm.service
systemctl start lightdm.service

sudo sed -i 's/greeter-session=.*/greeter-session=lightdm-slick-greeter/' /etc/lightdm/lightdm.conf

# Get our icon theme

git clone https://github.com/daniruiz/flat-remix
git clone https://github.com/daniruiz/flat-remix-gtk

mkdir -p ~/.icons && mkdir -p ~/.themes
cp -r flat-remix/Flat-Remix* ~/.icons/ && cp -r flat-remix-gtk/Flat-Remix-GTK* ~/.themes/

rm -rf flat*

# Set the themes

# Check original script for sed command to do this (check for file appearence before testing)


# install some applications for the desktop

yay -S --noconfirm discord


# Configuring the terminal 

## OH MY ZSH

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
