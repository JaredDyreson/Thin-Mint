#!/usr/bin/env bash

function make_root() {
  # DONE
	[[ "$(whoami)" != "root" ]] && (echo "Run as root!";exit)
	echo "$1 ALL=(ALL) ALL"  | tee -a /etc/sudoers
}

function password_manager(){
  # DONE
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

# REMOVED
function check_user() { [[ $(awk -F: '{print $user}' /etc/passwd | grep "$1") ]] && (return 1) || (return 0) }

function create_user() {
# DONE
	[[ -z "$user" || `check_user "$user"` ]] && exit
	useradd -m -g users -G wheel,storage,power -s /bin/zsh "$user"
	password_manager "$user"
	sudo -u "$user" bash -c "mkdir -p /home/"$user"/{Applications,archives,Downloads,Documents,Music,Pictures/Wallpapers,Projects,Video}"
	sudo -u "$user" bash -c "git clone https://github.com/JaredDyreson/dotfiles /home/"$user"/Projects/dotfiles"
	sudo -u "$user" bash -c "git clone https://github.com/JaredDyreson/university /home/"$user"/Projects/university"
}


function initial_configuration(){
  # DONE
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
	sudo -u "$user" bash -c "cp -ar /home/"$user"/Projects/dotfiles/wallpaper/* /home/"$user"/Pictures/Wallpapers/"
	sudo -u "$user" bash -c "dbus-launch dconf load / < /home/"$user"/Projects/dotfiles/desktop_env/arch_linux_settings"
}

function application_installer() {
	pacman -Sy --noconfirm vlc zenity firefox htop bluez blueman file-roller xreader virtualbox gedit
	declare -a yay_applications=('spotify' 'ffmpeg-compat-57' 'shutter' 'discord' 'balena-etcher' 'mintstick' 'pix')
	for application in "${yay_applications[@]}"; do
		sudo -u builduser bash -c "yay -Sy --noconfirm "$application""
	done
	find /usr/share/applications/ -type f \(-name "*java*" -o -name "*avahi*" \) -exec rm -rf {} \;
        if [[ -d /run/media/"$user"/External ]]; then
                cp -ar --no-preserve=mode /run/media/"$user"/External/firefox_data/* ~/.mozilla/
                chown -R "$user":users ~/.mozilla
        fi
  xdg-mime default xreader.desktop application/pdf   
}


function programming_environments(){
	pacman -Sy --noconfirm clang most jre-openjdk jdk-openjdk openjdk-doc python-pip texlive-most pandoc pdfgrep wget
	cd /tmp && git clone https://github.com/jeaye/stdman.git && cd stdman && ./configure && make install && mandb && cd .. && rm -rf stdman
        sudo -u "$user" bash -c "git clone https://github.com/JaredDyreson/scripts.git /home/"$user"/scripts"
        sudo -u "$user" bash -c "git clone https://github.com/JaredDyreson/starbucks_automa_production.git /tmp"
        pip3.8 install --upgrade google_auth_oauthlib google-api-python-client termcolor selenium
        
}

# Set up logging 
exec 1> >(tee "stdout.log")
exec 2> >(tee "stderr.log")

# we can get user
initial_configuration jared
# our desktop is up and running
desktop_manager
# we have the correct theme set
theme_manager

# this is the problem
dot_file_installer
application_installer
programming_environments
terminal_configuration
userdel -rf builduser
