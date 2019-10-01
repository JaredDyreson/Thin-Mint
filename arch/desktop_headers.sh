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
	echo "$user:$passone" | chpasswd "$user"
	echo "root:$passone" | chpasswd root
	export pass="$passone"
}

function check_user() { [[ $(awk -F: '{print $user}' /etc/passwd | grep "$1") ]] && (return 1) || (return 0) }

function create_user() {
	[[ -z "$user" || `check_user "$user"` ]] && exit
	useradd -m -g users -G wheel,storage,power -s /bin/zsh "$user"
	password_manager "$user"
	sudo -u "$user" bash -c "mkdir -p /home/"$user"/{Applications,archives,Downloads,Documents,Music,Pictures/Wallpapers,Projects,Video}"
	sudo -u "$user" bash -c "git clone https://github.com/JaredDyreson/dotfiles /home/"$user"/Projects/dotfiles"
	cat /home/"$user"/Projects/dotfiles/manifest_lists/repo_manifest | while read repo; do
		[[ $(echo "$repo" | awk '/university/ || /dotfiles/ {print $0}') ]] && break
		sudo -u "$user" bash -c "git clone "$repo" /home/"$user"/Projects/"$(basename "$repo" | sed 's/\.git//g')""
	done
}


function initial_configuration(){
	export user="$1"	
	[[ `check_user "$user"` ]] && (echo "Cannot process, $user is already a user";return)
	[[ -f /var/lib/pacman/db.lck ]] && rm /var/lib/pacman/db.lck  
	sed -i 's/builduser.*//g;s/'$user'.*//g' /etc/sudoers
	pacman -S --needed --noconfirm sudo git dialog python zsh
	[[ `check_user builduser` ]] || (useradd -s /bin/bash builduser -m && passwd -d builduser && make_root builduser)
	create_user "$user"
	make_root "$user"
	sudo -u builduser bash -c "git clone https://aur.archlinux.org/yay.git /home/builduser/yay && cd /home/builduser/yay && makepkg -si --noconfirm && cd .. && rm -rf yay"
}


## Functions that are used for the installation of the actual desktop environment 

function terminal_configuration() {
	sudo -u "$user" bash -c "cp -ar /home/"$user"/Projects/dotfiles/shell/zshrc /home/"$user"/.zshrc"
	curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash 
	sudo -u "$user" bash -c "git clone https://github.com/AlexisBRENON/oh-my-zsh-reminder /home/"$user"/.oh-my-zsh/custom/plugins/reminder"
	sudo -u "$user" bash -c "cp -ar /home/"$user"/Projects/dotfiles/shell/zshrc /home/"$user"/.zshrc"
	pacman -Sy --noconfirm vim cmake
	sudo -u builduser bash -c "yay -Sy --noconfirm vundle"
	#vim +silent +PluginInstall +qall
	#/usr/bin/python /home/"$user"/.vim/bundle/YouCompleteMe/install.py --clang-completer
	pacman -Sy --noconfirm rxvt-unicode xorg-xrdb ttf-dejavu powerline powerline-fonts ranger zsh-syntax-highlighting
}

function desktop_manager(){
	pacman -Sy --noconfirm xorg-server lightdm lightdm-gtk-greeter cinnamon noto-fonts
	sudo -u builduser bash -c "yay -Sy --noconfirm lightdm-slick-greeter"
	sed -i 's/#greeter-session=.*/greeter-session=lightdm-slick-greeter/' /etc/lightdm/lightdm.conf
	systemctl enable lightdm.service
	cp -ar /home/"$user"/Projects/dotfiles/desktop_env/slick-greeter.conf /etc/lightdm/
	cp -ar --no-preserve=mode /home/"$user"/Projects/dotfiles/wallpaper/* /etc/lightdm/
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
	sudo -u "$user" bash -c "mkdir -p /home/"$user"/.config/ranger"
	sudo -u "$user" bash -c "cp -ar /home/"$user"/Projects/dotfiles/ranger/* /home/"$user"/.config/ranger/"
	sudo -u "$user" bash -c "cp -ar /home/"$user"/Projects/dotfiles/terminal/Xresources /home/"$user"/.Xresources"
	sudo -u "$user" bash -c "cp -ar /home/"$user"/Projects/dotfiles/wallpaper/* /home/"$user"/Pictures/Wallpapers/"
	sudo -u "$user" bash -c "cp -ar /home/"$user"/Projects/dotfiles/shell/vimrc /home/"$user"/.vimrc"
	sudo -u "$user" bash -c "dbus-launch dconf load / < /home/"$user"/Projects/dotfiles/desktop_env/arch_linux_settings"
	git config --global user.name "Jared Dyreson"
	git config --global user.email "jared.dyreson@gmail.com"
}

function application_installer() {
	pacman -Sy --noconfirm vlc zenity firefox htop gnome-bluetooth file-roller 
	# vmware-workstation
	declare -a yay_applications=('spotify' 'ffmpeg-compat-57' 'shutter' 'discord' 'balena-etcher' 'mintstick' 'pix')
	for application in "${yay_applications[@]}"; do
		sudo -u builduser bash -c "yay -Sy --noconfirm "$application""
	done
	find /usr/share/applications/ -type f \(-name "*java*" -o -name "*avahi*" \) -exec rm -rf {} \;
}


function programming_environments(){
	pacman -Sy --noconfirm clang most jre-openjdk jdk-openjdk openjdk-doc python-pip texlive-most
	cd /tmp && git clone https://github.com/jeaye/stdman.git && cd stdman && ./configure && make install && mandb && cd .. && rm -rf stdman
	cat /tmp/dotfiles/manifest_lists/python_packages | while read package; do
		sudo pip install --upgrade "$package"
	done
}


function update_kernel(){
	pacman -Sy --noconfirm linux-hardened

}

function game_installers(){
	pacman -Sy --noconfirm minecraft-launcher steam steamcmd
}

function system_utilities(){
	pacman -Sy --noconfirm wget pdfgrep
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
sudo -u "$user" bash -c "git clone https://github.com/JaredDyreson/scripts.git /home/"$user"/scripts"
update_kernel
# game_installers
userdel -rf builduser
reboot
