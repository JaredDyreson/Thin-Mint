#!/usr/bin/env bash

# Cinnamon Desktop Environment script written by Jared Dyreson, all rights reserved
# Some helpful links
# Fixing ZSH Icons: https://unix.stackexchange.com/questions/429946/zsh-icons-broke-in-urxvt
# Font Settings for Panel: https://forums.linuxmint.com/viewtopic.php?t=106758
#	/usr/share/cinnamon/theme/cinnamon.css

### Set up logging ###
exec 1> >(tee "stdout.log")
exec 2> >(tee "stderr.log")


# HELPER FUNCTIONS #



initial_configuration

# Make me a user

clear

password_manager "$user"
echo "root:`head -n 1 /home/"$user"/pass`" | chpasswd root
su - "$user"
pass="$(head -n 1 ~/pass)"
echo "$pass" | sudo -S pacman -Sy --noconfirm zsh

# CONSOLODATION FUNCTIONS #



function terminal_configuration(){
}

function desktop_manager(){
	echo "$pass" | sudo -S pacman -Sy --noconfirm xorg-server lightdm lightdm-gtk-greeter cinnamon noto-fonts
	echo "$pass" | yay -Sy --noconfirm lightdm-slick-greeter
	sudo sed -i 's/#greeter-session=.*/greeter-session=lightdm-slick-greeter/' /etc/lightdm/lightdm.conf
	systemctl enable lightdm.service
}

function theme_manager() {
	# Get our icon theme
	cd /tmp
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
	dconf load / < /tmp/dotfiles/desktop_env/arch_cinnamon_settings

	git config --global user.name "Jared Dyreson"
	git config --global user.email "jared.dyreson@gmail.com"
	`cd ~ && git clone https://github.com/JaredDyreson/scripts.git`

}

function application_installer() {

	### install yay first (so we can install "unofficial" packages using pacman)

	
	# Applications

	## VMWare, Spotfiy (zenity and ffmpeg-compat-57 for media playback), VLC, Firefox

	echo "$pass" | sudo -S pacman -Sy --noconfirm vlc zenity firefox
	echo "$pass" | yay -Sy --noconfirm spotify vmware-workstation ffmpeg-compat-57 shutter

	## Firefox Configuration (Extensions and profile are copied over)

	#./brew pull firefox_configuration.tar
	#tar -xvf /tmp/dotfiles/firefox/firefox_configuration.tar -C ~/.mozilla
	## Discord

	yay -S --noconfirm discord

	## Etcher, USB Formater (directly from Mint)

	echo "$pass" | yay -Sy --noconfirm balena-etcher mintstick

	## Image viewer and xreader (Also from Mint), as well as gimp

	echo "$pass" | yay -Sy --noconfirm pix 
	echo "$pass" | sudo -S pacman -Sy --noconfirm xreader gimp imagemagick

	## Calculator and other production needs

	echo "$pass" | sudo -S pacman -Sy --noconfirm gnome-calculator libreoffice-still

	## System Monitoring

	echo "$pass" | sudo -S pacman -Sy --noconfirm htop gnome-bluetooth
	
	# archive manager
	echo "$pass" | sudo -S pacman -Sy --noconfirm file-roller
	echo "$pass" | sudo -S find /usr/share/applications/ -type f \(-name "*java*" -o -name "*avahi*" \) -exec rm -rf {} \;

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
		echo "$pass" | sudo -S rm -rf /tmp/*
	done
}

function clean_up(){
	userdel builduser
	rm -rf ~/pass
	usermod -s /bin/zsh "$user"
	reboot
}

function main() {
	terminal_configuration
	desktop_manager
	theme_manager
	home_directory_structure
	dot_file_installer
	application_installer
	# pacman -Sy --noconfirm texlive-most
	programming_environments
	clean_up

}
case "${@:2}" in
	--all)
		main
		;;
	--init)
		initial_configuration
		;;
	--create-user)
		create_user_space
		;;
	--term-config)
		terminal_configuration
		;;
	--desktop-config)
		desktop_manager
		;;
	--theme-config)
		theme_manager
		;;
	--home-struct)
		home_directory_structure
		;;
	--application-config)
		application_installer
		;;
	--programming-config)
		programming_environments
		;;
	--clean-up)
		cleanup
		;;
	--help)
		echo "[-] Print help message"
		;;
esac
