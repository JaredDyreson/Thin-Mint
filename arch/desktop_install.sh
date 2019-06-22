#!/usr/bin/env bash

# Cinnamon Desktop Environment script written by Jared Dyreson, all rights reserved

### Set up logging ###
exec 1> >(tee "stdout.log")
exec 2> >(tee "stderr.log")


# HELPER FUNCTIONS #

function make_root() {
	[[ "$(whoami)" != "root" ]] && (echo "Run as root!";exit)
	echo "$1 ALL=(ALL) ALL"  | tee -a /etc/sudoers
}

function password_manager(){
	[[ -z "$1" ]] && return
	password_one=""
	password_two="different"
	while [[ "$password_one" != "$password_two" || -z "$password_one" || -z "$password_two" ]]; do
		password_one=$(dialog --stdout --passwordbox "Enter admin password" 0 0) || exit 1
		clear
		[[ -z "$password_one" ]] && (echo "Password cannot be nothing")
		password_two=$(dialog --stdout --passwordbox "Enter admin password again" 0 0) || exit 1
		clear
		[[ "$password" != "$password2" ]] && ( echo "Passwords did not match";)	
	done
	echo "$1:$password_one" | chpasswd "$1"
	echo "$password_one" >> /home/"$1"/pass
}

function create_user() {
	[[ -z "$1" ]] && exit
	useradd -m -g users -G wheel,storage,power -s /bin/bash "$1" 
}

function initial_configuration(){
	# making a builder account so we can run makepkg as "root"
	[[ -f /var/lib/pacman/db.lck ]] && rm /var/lib/pacman/db.lck  
	sed -i 's/builduser.*//g;s/jared.*//g' /etc/sudoers
	pacman -S --needed --noconfirm sudo git dialog # Install sudo
	useradd builduser -m # Create the builduser
	passwd -d builduser # Delete the buildusers password
	make_root builduser

	cd /tmp
	[[ -d dotfiles ]] && rm -rf dotfiles
	git clone https://github.com/JaredDyreson/dotfiles.git

}

initial_configuration

# Make me a user
user="jared"
create_user "$user"
make_root "$user"

clear

password_manager "$user"
echo "root:`head -n 1 /home/"$user"/pass`" | chpasswd root
su - "$user"
pass="$(head -n 1 ~/pass)"
echo "$pass" | sudo -S pacman -Sy --noconfirm zsh

# CONSOLODATION FUNCTIONS #



function terminal_configuration(){
	## OH MY ZSH

	curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh  >> omzinstaller
	[[ -s "./omzinstaller" ]] && chmod +x ./omzinstaller
	echo "Y" | ./omzinstaller
	cp -ar /tmp/dotfiles/shell/zshrc ~/.zshrc

	## VIM
	echo "$pass" | sudo -S pacman -Sy --noconfirm vim
	cp -ar /tmp/dotfiles/shell/vimrc ~/.vimrc
	
	## Ranger
	echo "$pass" | sudo -S pacman -Sy --noconfirm ranger

	## URXVT	
	echo "$pass" | sudo -S pacman -Sy --noconfirm rxvt-unicode xorg-xrdb

}

function desktop_manager(){
	echo "$pass" | sudo -S pacman -Sy --noconfirm xorg-server lightdm lightdm-gtk-greeter cinnamon noto-fonts
	echo "$pass" | yay -Sy --noconfirm https://aur.archlinux.org/lightdm-slick-greeter.git 
	sudo sed -i 's/#greeter-session=.*/greeter-session=lightdm-slick-greeter/' /etc/lightdm/lightdm.conf
	systemctl enable lightdm.service
}

function theme_manager() {
	# Get our icon theme
	cd /tmp
#	echo "$pass" | yay -Sy --noconfirm https://aur.archlinux.org/mint-x-icons.git https://aur.archlinux.org/mint-y-icons.git https://aur.archlinux.org/mint-themes.git
	echo "$pass" | yay -Sy --noconfirm mint-x-icons mint-y-icons mint-themes
	git clone https://github.com/daniruiz/flat-remix
	git clone https://github.com/daniruiz/flat-remix-gtk

	mkdir -p ~/{.icons,.themes}
	cp -r flat-remix/Flat-Remix* ~/.icons/ && cp -r flat-remix-gtk/Flat-Remix-GTK* ~/.themes/

	rm -rf flat*
}

function dot_file_installer() {
	## File manager [Ranger]
	mkdir ~/.config/ranger 
	cp -ar /tmp/dotfiles/ranger/* ~/.config/ranger/

	## URXVT
	cp -ar /tmp/dotfiles/terminal/Xresources ~/.Xresources

	## Cinnamon Settings
	cp -ar /tmp/dotfiles/wallpaper/* ~/Pictures/Wallpapers/
	dconf load /org/cinnamon/ < /tmp/dotfiles/desktop_env/settings

	git config --global user.name "Jared Dyreson"
	git config --global user.email "jared.dyreson@gmail.com"
	`cd ~ && git clone https://github.com/JaredDyreson/scripts.git`

}

function home_directory_structure() {
	mkdir -p ~/{Applications,archives,Downloads,Documents,Music,Pictures/Wallpapers,Projects,Video}
	cd ~/Projects
	cat /tmp/dotfiles/manifest_lists/repo_manifest | while read line; do
		git clone "$line"
	done
}
function application_installer() {

	### install yay first (so we can install "unofficial" packages using pacman)

	git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay
	
	# Applications

	## VMWare, Spotfiy (zenity and ffmpeg-compat-57 for media playback), VLC, Firefox

	echo "$pass" | sudo -S pacman -Sy --noconfirm vmware-workstation vlc zenity ffmpeg-compat-57 firefox
	echo "$pass" | yay -Sy --noconfirm spotify
	## Discord

	yay -S --noconfirm discord

	## Etcher, USB Formater (directly from Mint)

	# echo "$pass" | yay -Sy --noconfirm https://aur.archlinux.org/balena-etcher.git https://aur.archlinux.org/mintstick.git

	## Image viewer and xreader (Also from Mint), as well as gimp

	echo "$pass" | yay -Sy --noconfirm pix 
	echo "$pass" | sudo -S pacman -Sy --noconfirm xreader gimp imagemagick

	## Calculator and other production needs

	echo "$pass" | sudo -S pacman -Sy --noconfirm gnome-calculator libreoffice-still

	## System Monitoring

	echo "$pass" | sudo -S pacman -Sy --noconfirm htop gnome-bluetooth
	
	# archive manager
	echo "$pass" | sudo -S pacman -Sy --noconfirm file-roller

}

function programming_environments() {
	# C++ Environment

	## Clang

	echo "$pass" | sudo -S pacman -Sy --noconfirm clang

	## std::man pages

	echo "$pass" | sudo -S pacman -Sy --noconfirm most
	cd /tmp && git clone https://github.com/jeaye/stdman.git && cd stdman && ./configure && echo "$pass" | sudo -S make install && echo "$pass" | sudo -S mandb && cd .. && rm -rf stdman


	# Java Environment

	echo "$pass" | sudo -S pacman -Sy --noconfirm jre-openjdk jdk-openjdk openjdk-doc

	# Python

	## so we don't have to fix starbucks_automa
	echo "$pass" | sudo -S pacman -Sy --noconfirm python-pip 
	cat /tmp/dotfiles/manifest_lists/python_packages | while read line; do
		sudo pip install --upgrade "$line"
		sudo pip3 install --upgrade "$line"
		rm -rf /tmp/*
	done
}

# Make it look like Linux Mint

## Terminal

terminal_configuration

## Install the Display Manager and Desktop Environmnet

desktop_manager

## Theme it up

theme_manager

## Get all of the folders we need

home_directory_structure

## Config files

dot_file_installer

## Applications

application_installer

## LaTeX Environment

# pacman -Sy --noconfirm texlive-most

# Programming

programming_environments

# Clean up

userdel builduser
# change back to zsh shell
rm -rf ~/pass
echo "$pass" | sudo -S find /usr/share/applications/ -type f \(-name "*java*" -o -name "*avahi*" \) -exec rm -rf {} \;
usermod -s /bin/zsh "$user"
echo "$pass" | sudo -S rm -rf /tmp/*
