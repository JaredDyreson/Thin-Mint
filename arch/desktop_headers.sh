#!/usr/bin/env bash

function make_root() {
	[[ "$(whoami)" != "root" ]] && (echo "Run as root!";exit)
	echo "$1 ALL=(ALL) ALL"  | tee -a /etc/sudoers
}

function password_manager(){
	passone=""
	passtwo="d"
	while [[ -z "$passone" || "$passone" != "$passtwo" ]]; do
		passone=$(dialog --stdout --passwordbox "Enter admin password" 0 0) || exit 1
		clear
		passtwo=$(dialog --stdout --passwordbox "Enter admin password again" 0 0) || exit 1
		clear
	done
	echo "$1:$passone" | chpasswd "$1"
	echo "root:$passone" | chpasswd root
	export pass="$passone"
}

function check_user() { [[ $(awk -F: '{print $1}' /etc/passwd | grep "$1") ]] && (return 1) || (return 0) }

function create_user() {
	[[ -z "$1" || `check_user "$1"` ]] && exit
	useradd -m -g users -G wheel,storage,power -s /bin/zsh "$1"
	password_manager "$1"
	sudo -u "$1" bash -c "mkdir -p /home/"$1"/{Applications,archives,Downloads,Documents,Music,Pictures/Wallpapers,Projects,Video}"
	cat /tmp/dotfiles/manifest_lists/repo_manifest | while read line; do
		[[ $(echo "$line" | grep 'university') ]] && break
		git clone "$line" /home/"$1"/Projects/"$(basename "$line" | sed 's/\.git//g')"
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
	sudo -u "$user" bash -c "cp -ar /tmp/dotfiles/shell/zshrc /home/"$user"/.zshrc"
	curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash 
	git clone https://github.com/AlexisBRENON/oh-my-zsh-reminder /home/"$user"/.oh-my-zsh/custom/plugins/reminder
	pacman -Sy --noconfirm vim cmake
	sudo -u builduser bash -c "yay -Sy --noconfirm vundle"
	sudo -u "$user" bash -c "cp -ar /tmp/dotfiles/shell/vimrc /home/"$user"/.vimrc"
	vim +silent +PluginInstall +qall
	/usr/bin/python /home/"$user"/.vim/bundle/YouCompleteMe/install.py --clang-completer
	pacman -Sy --noconfirm rxvt-unicode xorg-xrdb ttf-dejavu powerline powerline-fonts ranger
}

function desktop_manager(){
	pacman -Sy --noconfirm xorg-server lightdm lightdm-gtk-greeter cinnamon noto-fonts
	sudo -u builduser bash -c "yay -Sy --noconfirm lightdm-slick-greeter"
	sudo sed -i 's/#greeter-session=.*/greeter-session=lightdm-slick-greeter/' /etc/lightdm/lightdm.conf
	systemctl enable lightdm.service
}


function theme_manager() {
	declare -a themes=('mint-x-icons' 'mint-y-icons' 'mint-themes')
	for theme in "${themes[@]}"; do
		sudo -u builduser bash -c "yay -Sy --noconfirm "$theme""
	done
	sudo -u "$user" bash -c "mkdir -p /home/"$user"/{.icons,.themes}"
	git clone https://github.com/daniruiz/flat-remix /home/"$user"/.icons/
	git clone https://github.com/daniruiz/flat-remix-gtk /home/"$user"/.themes/
}

function dot_file_installer() {
	mkdir -p /home/"$user"/.config/ranger 
	sudo -u "$user" bash -c "cp -ar /home/"$user"/Projects/dotfiles/ranger/* /home/"$user"/.config/ranger/"
	sudo -u "$user" bash -c "cp -ar /home/"$user"/Projects/dotfiles/terminal/Xresources /home/"$user"/.Xresources"
	sudo -u "$user" bash -c "cp -ar /home/"$user"/Projects/dotfiles/wallpaper/* /home/"$user"/Pictures/Wallpapers/"
	dconf load / < /home/"$user"/Projects/dotfiles/desktop_env/arch_cinnamon_settings
	git config --global user.name "Jared Dyreson"
	git config --global user.email "jared.dyreson@gmail.com"
	`git clone https://github.com/JaredDyreson/scripts.git /home/"$user"/scripts`
}

function application_installer() {
	pacman -Sy --noconfirm vlc zenity firefox htop gnome-bluetooth file-roller 
	# vmware-workstation
	declare -a yay_applications=('spotify' 'ffmpeg-compat-57' 'shutter' 'vmware-workstation' 'discord' 'balena-etcher' 'mintstick' 'pix')
	for application in "${yay_applications[@]}"; do
		sudo -u builduser bash -c "yay -Sy --noconfirm "$application""
	done
	find /usr/share/applications/ -type f \(-name "*java*" -o -name "*avahi*" \) -exec rm -rf {} \;
}


function programming_environments(){
	pacman -Sy --noconfirm clang most jre-openjdk jdk-openjdk openjdk-doc python-pip texlive-most
	cd /tmp && git clone https://github.com/jeaye/stdman.git && cd stdman && ./configure && make install && mandb && cd .. && rm -rf stdman
	cat /tmp/dotfiles/manifest_lists/python_packages | while read line; do
		sudo pip install --upgrade "$line"
	done
}

# Set up logging 
exec 1> >(tee "stdout.log")
exec 2> >(tee "stderr.log")

initial_configuration jared
desktop_manager
theme_manager
dot_file_installer
application_installer
programming_environments
terminal_configuration
userdel -rf builduser
reboot
