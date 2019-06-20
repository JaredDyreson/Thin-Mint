#!/usr/bin/env bash

# this is important if you want to install packages after you install (DUH!)

function make_root() {
	[[ "$(whoami)" != "root" ]] && (echo "Run as root!";exit)
	echo "$1 ALL=(ALL) ALL"  >> /etc/sudoers
}

function install_git_package() {
	waypoint="$(pwd)"
	for repo in "$@"; do
		#[[ "$(curl -Is git clone "$repo" 2> /dev/null | head -n 1 | grep -i "ok")" || -z "$repo" ]] || (echo "Link cannot be reached, cowardly refusing" && break)
		go_here="$(basename "$repo" | sed 's/\.git//g')"
		sudo -u builduser bash -c 'cd /tmp && git clone '$1' && cd '$go_here' && makepkg -si --noconfirm && cd '$waypoint''
		rm -rf /tmp/"$go_here"
	done
}

# making a builder account so we can run makepkg as "root"

### Set up logging ###
exec 1> >(tee "stdout.log")
exec 2> >(tee "stderr.log")

sed -i 's/builduser.*//g;s/jared.*//g' /etc/sudoers
pacman -S --needed --noconfirm sudo # Install sudo
useradd builduser -m # Create the builduser
passwd -d builduser # Delete the buildusers password
printf 'builduser ALL=(ALL) ALL\n' | tee -a /etc/sudoers # Allow the builduser passwordless sudo

# install yay first

install_git_package https://aur.archlinux.org/yay.git
useradd -mU -s /bin/zsh -G wheel jared
printf 'jared ALL=(ALL) ALL\n' | tee -a /etc/sudoers.d

# Make it look like Linux Mint


cd /tmp && git clone https://github.com/JaredDyreson/dotfiles.git

# Install the Display Manager and theme

pacman -Sy --noconfirm xorg-server lightdm lightdm-gtk-greeter cinnamon
sudo sed -i 's/#greeter-session=.*/greeter-session=lightdm-slick-greeter/' /etc/lightdm/lightdm.conf
systemctl enable lightdm.service
#systemctl start lightdm.service

# Get our icon theme

install_git_package https://aur.archlinux.org/mint-x-icons.git https://aur.archlinux.org/mint-y-icons.git https://aur.archlinux.org/mint-themes.git

git clone https://github.com/daniruiz/flat-remix
git clone https://github.com/daniruiz/flat-remix-gtk

mkdir -p /home/jared/{.icons,.themes}
cp -r flat-remix/Flat-Remix* /home/jared/.icons/ && cp -r flat-remix-gtk/Flat-Remix-GTK* /home/jared/.themes/

rm -rf flat*

exit
# Get all of the folders we need

mkdir -p /home/jared/{Applications,archives,Downloads,Documents,Music,Pictures,Projects,Video}

cd /home/jared/Projects
cat /tmp/dotfiles/desktop_env/manifest | while read line; do
	git clone "$line"
done

# Use dotfiles

## File manager
pacman -Sy --noconfirm ranger
cp -ar /tmp/dotfiles/ranger/* /home/jared/.config/ranger/

## URXVT

pacman -Sy rxvt-unicode xorg-xrdb
cp -ar /tmp/dotfiles/terminal/Xresources /home/jared/.Xresources
xrdb /home/jared/.Xresources

## Cinnamon Settings
dconf load /org/cinnamon < /tmp/dotfiles/desktop_env/settings

## Remapping ESC to CAPS!
pacman -Sy --noconfirm xorg-setxkmap
echo "setxkbmap -option caps:swapescape" >> /home/jared/.xinitrc

# Configuring the terminal 

## OH MY ZSH

pacman -Sy --noconfirm zsh
useradd -mU -s /bin/zsh -G wheel
curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sed 's:env zsh -l::g' | sed 's:chsh -s .*$::g' >> omzinstaller
[[ -s "./omzinstaller" ]] && chmod +x ./omzinstaller && ./omzinstaller --unattended

## Shell things (update zshrc and make vim the default editor)
pacman -Sy --noconfirm vim
cp -ar /tmp/dotfiles/shell/zshrc /home/jared/.zshrc
cp -ar /tmp/dotfiles/shell/vimrc /home/jared/.vimrc
[[  "$EDITOR" !=  "vim" ]] && (sed -i "/export\ EDITOR/s/'.*'/'vim'/" "$HOME"/.zshrc)

## Scripts and git configuration


# Applications

## VMWare, Spotfiy (zenity and ffmpeg-compat-57 for media playback), VLC

pacman -Sy --noconfirm vmware-workstation spotify vlc zenity ffmpeg-compat-57

## Discord

yay -S --noconfirm discord

## Etcher, USB Formater (directly from Mint)

install_git_package https://aur.archlinux.org/balena-etcher.git https://aur.archlinux.org/mintstick.git

## Image viewer and xreader (Also from Mint), as well as gimp

install_git_package https://aur.archlinux.org/pix.git 
pacman -Sy --noconfirm xreader gimp imagemagick

## Markdown Client (Mostly for looks)

wget -qO package "https://github.com/notable/notable/releases/download/v1.5.1/Notable-1.5.1.pkg" && pacman -S package && rm -rf package

## Calculator and other production needs

pacman -Sy --noconfirm gnome-calculator libreoffice-still

## System Monitoring

pacman -Sy --noconfirm htop gnome-bluetooth

## LaTeX Environment

# pacman -Sy --noconfirm texlive-most

# C++ Environment

## Clang

pacman -Sy --noconfirm clang

## std::man pages

pacman -Sy --noconfirm most
cd /tmp && git clone https://github.com/jeaye/stdman.git && cd stdman && ./configure && sudo make install && sudo mandb && cd .. && rm -rf stdman


# Java Environment

pacman -Sy --noconfirm jre-openjdk

# Delete builduser

userdel builduser
git config --global user.name "Jared Dyreson"
git config --global user.email "jared.dyreson@gmail.com"
`cd /home/jared && git clone https://github.com/JaredDyreson/scripts.git`

