#!/usr/bin/env bash

# Header files for desktop_installer_main.sh #

## Functions that are used for creating a user space ##

function make_root() {
	[[ "$(whoami)" != "root" ]] && (echo "Run as root!";exit)
	echo "$1 ALL=(ALL) ALL"  | tee -a /etc/sudoers
}

function password_manager(){
	# REFACTOR #
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
	echo "root:$password_one" | chpasswd root
	export pass="$password_one"
}

function check_user() { [[ $(awk -F: '{print $1}' /etc/passwd | grep "$1") ]] && return true || return false }

function create_user() {
	[[ -z "$1" || `check_user "$1"` ]] && exit
	useradd -m -g users -G wheel,storage,power -s /bin/zsh "$1"
	password_manager "$1"
	mkdir -p ~/{Applications,archives,Downloads,Documents,Music,Pictures/Wallpapers,Projects,Video}
	cd ~/Projects
	cat /tmp/dotfiles/manifest_lists/repo_manifest | while read line; do
		git clone "$line"
	done
}


function initial_configuration(){
	[[ check_user "$1" ]] && (echo "Cannot process, $1 is already a user";return)
	[[ -f /var/lib/pacman/db.lck ]] && rm /var/lib/pacman/db.lck  
	sed -i 's/builduser.*//g;s/'$1'.*//g' /etc/sudoers
	pacman -S --needed --noconfirm sudo git dialog python zsh
	[[ check_user builduser ]] || (useradd builduser -m && passwd -d builduser && make_root builduser)
	[[ -d /tmp/dotfiles ]] && rm -rf /tmp/dotfiles
	git clone https://github.com/JaredDyreson/dotfiles.git /tmp/dotfiles
	u="$1"
	create_user "$u"
	make_root "$u"
	su - builduser
	git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay
	export user="$u"	
}


## Functions that are used for the installation of the actual desktop environment ##

function terminal_configuration() {
	curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh  >> omzinstaller
	chmod +x ./omzinstaller
	echo "Y" | ./omzinstaller
	git clone https://github.com/AlexisBRENON/oh-my-zsh-reminder ~/.oh-my-zsh/custom/plugins/reminder
	cp -ar /tmp/dotfiles/shell/zshrc ~/.zshrc
	echo "$pass" | sudo -S pacman -Sy --noconfirm vim cmake
	echo "$pass" | yay -Sy --noconfirm vundle
	cp -ar /tmp/dotfiles/shell/vimrc ~/.vimrc
	vim +PluginInstall +qall
	/usr/bin/python ~/.vim/bundle/YouCompleteMe/install.py --clang-completer
	echo "$pass" | sudo -S pacman -Sy --noconfirm rxvt-unicode xorg-xrdb ttf-dejavu powerline powerline-fonts ranger

}

# sets user and pass
initial_configuration
echo "User: $user"
echo "Password: $pass"

