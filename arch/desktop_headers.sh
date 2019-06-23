#!/usr/bin/env bash

# Header files for desktop_installer_main.sh 

## Functions that are used for creating a user space 

function make_root() {
	[[ "$(whoami)" != "root" ]] && (echo "Run as root!";exit)
	echo "$1 ALL=(ALL) ALL"  | tee -a /etc/sudoers
}

function password_manager(){
	# REFACTOR 
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

function check_user() { [[ $(awk -F: '{print $1}' /etc/passwd | grep "$1") ]] && (return 1) || (return 0) }

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
	[[ `check_user "$1"` ]] && (echo "Cannot process, $1 is already a user";return)
	[[ -f /var/lib/pacman/db.lck ]] && rm /var/lib/pacman/db.lck  
	sed -i 's/builduser.*//g;s/'$1'.*//g' /etc/sudoers
	pacman -S --needed --noconfirm sudo git dialog python zsh
	[[ `check_user builduser` ]] || (useradd builduser -m && passwd -d builduser && make_root builduser)
	[[ -d /tmp/dotfiles ]] && rm -rf /tmp/dotfiles
	git clone https://github.com/JaredDyreson/dotfiles.git /tmp/dotfiles
	u="$1"
	create_user "$u"
	make_root "$u"
	sudo -u builduser bash -c "git clone https://aur.archlinux.org/yay.git /home/builduser/yay && cd /home/builduser/yay && makepkg -si --noconfirm && cd .. && rm -rf yay"
	export user="$u"	
}


## Functions that are used for the installation of the actual desktop environment 

function terminal_configuration() {
	curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh  >> omzinstaller
	chmod +x ./omzinstaller
	echo "Y" | ./omzinstaller
	git clone https://github.com/AlexisBRENON/oh-my-zsh-reminder ~/.oh-my-zsh/custom/plugins/reminder
	cp -ar /tmp/dotfiles/shell/zshrc ~/.zshrc
	echo "$pass" | sudo -S pacman -Sy --noconfirm vim cmake
	echo "$pass" | yay -Sy --noconfirm vundle
	cp -ar /tmp/dotfiles/shell/vimrc ~/.vimrc
	vim -u +PluginInstall +qall
	/usr/bin/python ~/.vim/bundle/YouCompleteMe/install.py --clang-completer
	echo "$pass" | sudo -S pacman -Sy --noconfirm rxvt-unicode xorg-xrdb ttf-dejavu powerline powerline-fonts ranger
}

function desktop_manager(){
	echo "$pass" | sudo -S pacman -Sy --noconfirm xorg-server lightdm lightdm-gtk-greeter cinnamon noto-fonts
	echo "$pass" | yay -Sy --noconfirm lightdm-slick-greeter
	sudo sed -i 's/#greeter-session=.*/greeter-session=lightdm-slick-greeter/' /etc/lightdm/lightdm.conf
	systemctl enable lightdm.service
}


function theme_manager() {
	cd /tmp
	echo "$pass" | yay -Sy --noconfirm mint-x-icons mint-y-icons mint-themes
	git clone https://github.com/daniruiz/flat-remix
	git clone https://github.com/daniruiz/flat-remix-gtk
	mkdir -p ~/{.icons,.themes}
	cp -r flat-remix/Flat-Remix* ~/.icons/ && cp -r flat-remix-gtk/Flat-Remix-GTK* ~/.themes/
	rm -rf flat*
}

function dot_file_installer() {
	mkdir ~/.config/ranger 
	cp -ar /tmp/dotfiles/ranger/* ~/.config/ranger/
	cp -ar /tmp/dotfiles/terminal/Xresources ~/.Xresources
	cp -ar /tmp/dotfiles/wallpaper/* ~/Pictures/Wallpapers/
	dconf load / < /tmp/dotfiles/desktop_env/arch_cinnamon_settings
	git config --global user.name "Jared Dyreson"
	git config --global user.email "jared.dyreson@gmail.com"
	`cd ~ && git clone https://github.com/JaredDyreson/scripts.git`
}

function application_installer() {
	echo "$pass" | sudo -S pacman -Sy --noconfirm vlc zenity firefox htop gnome-bluetooth file-roller 
	echo "$pass" | yay -Sy --noconfirm spotify vmware-workstation ffmpeg-compat-57 shutter discord balena-etcher mintstick pix
	echo "$pass" | sudo -S find /usr/share/applications/ -type f \(-name "*java*" -o -name "*avahi*" \) -exec rm -rf {} \;
}


function programming_environments(){
	echo "$pass" | sudo -S pacman -Sy --noconfirm clang most jre-openjdk jdk-openjdk openjdk-doc python-pip

	cd /tmp && git clone https://github.com/jeaye/stdman.git && cd stdman && ./configure && echo "$pass" | sudo -S make install && echo "$pass" | sudo -S mandb && cd .. && rm -rf stdman

	cat /tmp/dotfiles/manifest_lists/python_packages | while read line; do
		sudo pip install --upgrade "$line"
		sudo pip3 install --upgrade "$line"
	done

}
function clean_up(){
	userdel builduser
	rm -rf ~/pass
	usermod -s /bin/zsh "$user"
	reboot
}

### Set up logging ###
exec 1> >(tee "stdout.log")
exec 2> >(tee "stderr.log")

initial_configuration jared
desktop_manager
theme_manager
home_directory_structure
dot_file_installer
application_installer
programming_environments
terminal_configuration
userdel builduser
reboot
