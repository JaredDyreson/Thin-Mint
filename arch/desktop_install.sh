#!/usr/bin/env bash



# TODO
# rewrite entire script, adding and deleting things
# mitigate most of these to functions so it is neater

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


# making a builder account so we can run makepkg as "root"

sed -i 's/builduser.*//g;s/jared.*//g' /etc/sudoers
pacman -S --needed --noconfirm sudo # Install sudo
useradd builduser -m # Create the builduser
passwd -d builduser # Delete the buildusers password
make_root builduser

# install yay first (so we can install "unofficial" packages using pacman)

install_git_package https://aur.archlinux.org/yay.git

# Make me a user
user="jared"
create_user "$user"
pass="$(head -n 1 /home/"$user"/pass)"
make_root "$user"

clear

password_manager "$user"
su - "$user"
echo "$pass" | sudo -S pacman -Sy --noconfirm zsh


# Make it look like Linux Mint


cd /tmp
[[ -d dotfiles ]] && rm -rf dotfiles
git clone https://github.com/JaredDyreson/dotfiles.git

# Configuring the terminal 

## OH MY ZSH

curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh  >> omzinstaller
[[ -s "./omzinstaller" ]] && chmod +x ./omzinstaller
echo "Y" | ./omzinstaller
cp -ar /tmp/dotfiles/shell/zshrc ~/.zshrc


## VIM
echo "$pass" | sudo -S pacman -Sy --noconfirm vim
cp -ar /tmp/dotfiles/shell/vimrc ~/.vimrc

# Install the Display Manager and Desktop Environmnet

echo "$pass" | sudo -S pacman -Sy --noconfirm xorg-server lightdm lightdm-gtk-greeter cinnamon
install_git_package https://aur.archlinux.org/lightdm-slick-greeter.git 
sudo sed -i 's/#greeter-session=.*/greeter-session=lightdm-gtk-greeter/' /etc/lightdm/lightdm.conf
systemctl enable lightdm.service

# Get our icon theme

install_git_package https://aur.archlinux.org/mint-x-icons.git https://aur.archlinux.org/mint-y-icons.git https://aur.archlinux.org/mint-themes.git

git clone https://github.com/daniruiz/flat-remix
git clone https://github.com/daniruiz/flat-remix-gtk

mkdir -p /home/"$user"/{.icons,.themes}
cp -r flat-remix/Flat-Remix* /home/"$user"/.icons/ && cp -r flat-remix-gtk/Flat-Remix-GTK* /home/"$user"/.themes/

rm -rf flat*

# Get all of the folders we need

mkdir -p /home/"$user"/{Applications,archives,Downloads,Documents,Music,Pictures/Wallpapers,Projects,Video}

cd /home/"$user"/Projects
cat /tmp/dotfiles/repo_lists/manifest | while read line; do
	git clone "$line"
done

# Use dotfiles

## File manager
echo "$pass" | sudo -S pacman -Sy --noconfirm ranger
## we want to allow for ranger to create the necessary intial configuration files
ranger & disown
sleep 10
pkill ranger
cp -ar /tmp/dotfiles/ranger/* ~/.config/ranger/

## URXVT
echo "$pass" | sudo -S pacman -Sy --noconfirm rxvt-unicode xorg-xrdb
cp -ar /tmp/dotfiles/terminal/Xresources ~/.Xresources

## Cinnamon Settings
cp -ar /tmp/dotfiles/wallpaper/* ~/Pictures/Wallpapers/
dconf load /org/cinnamon/ < /tmp/dotfiles/desktop_env/settings

## Remapping ESC to CAPS!
# sudo pacman -Sy --noconfirm xorg-setxkmap
# echo "setxkbmap -option caps:swapescape" >> /home/"$user"/.xinitrc

# Applications

## VMWare, Spotfiy (zenity and ffmpeg-compat-57 for media playback), VLC, Firefox

echo "$pass" | sudo -S pacman -Sy --noconfirm vmware-workstation spotify vlc zenity ffmpeg-compat-57 firefox

## Discord

yay -S --noconfirm discord

## Etcher, USB Formater (directly from Mint)

# install_git_package https://aur.archlinux.org/balena-etcher.git https://aur.archlinux.org/mintstick.git

## Image viewer and xreader (Also from Mint), as well as gimp

install_git_package https://aur.archlinux.org/pix.git 
echo "$pass" | sudo -S pacman -Sy --noconfirm xreader gimp imagemagick

## Calculator and other production needs

echo "$pass" | sudo -S pacman -Sy --noconfirm gnome-calculator libreoffice-still

## System Monitoring

echo "$pass" | sudo -S pacman -Sy --noconfirm htop gnome-bluetooth

## LaTeX Environment

# pacman -Sy --noconfirm texlive-most

# C++ Environment

## Clang

echo "$pass" | sudo -S pacman -Sy --noconfirm clang

## std::man pages

echo "$pass" | sudo -S pacman -Sy --noconfirm most
cd /tmp && git clone https://github.com/jeaye/stdman.git && cd stdman && ./configure && echo "$pass" | sudo -S make install && echo "$pass" | sudo -S mandb && cd .. && rm -rf stdman


# Java Environment

echo "$pass" | sudo -S pacman -Sy --noconfirm jre-openjdk jdk-openjdk openjdk-doc

# Delete builduser

userdel builduser
git config --global user.name "Jared Dyreson"
git config --global user.email "jared.dyreson@gmail.com"
`cd /home/"$user" && git clone https://github.com/JaredDyreson/scripts.git`
# change back to zsh shell
usermod -s /bin/zsh "$user"
systemctl start lightdm.service
rm -rf /home/"$user"/pass
