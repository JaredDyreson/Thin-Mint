#!/usr/bin/env bash

# Task: scripts to be run inside a arch-chroot environment

# NOTE
# this is not meant to be "neat", just a raw installer for the Arch-ISO
# THERE IS CODE THAT IS SHARED BETWEEN ALL OF THE OTHER SCRIPTS, THIS IS MEANT TO BE INDEPENDENT

# task: run setup inside of the arch-chroot environment
# AUTHOR: Jared Dyreson, CSUF 2021

## HELPER FUNCTIONS BEGIN ##

function make_root() {
	[[ "$EUID" -ne -0 || -z "$@" ]] && exit
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

function create_user() {
	useradd -m -g users -G wheel,storage,power -s /bin/zsh "$user"
	password_manager "$user"
	sudo -u "$user" bash -c "mkdir -p /home/"$user"/{Applications,archives,Downloads,Documents,Music,Pictures/Wallpapers,Projects,Video}"
}

## HELPER FUNCTIONS END ## 

## BASE INSTALL BEGIN ##

# CONSTANTS #

hostname="jared-xps"
user="jared"
EXT_BASE="/run/media/$USER/External"
PKG_SRC="/run/media/jared/External/compiled_arch_binaries/yay_compiled/"

[[ ! -d "$PKG_SRC" ]] && exit

# timezone

ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

# sync the time

hwclock --systohc --utc

# we want English as primary language

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# what is our machine's name to the world

echo "$hostname" > /etc/hostname

# make sure this name is reflected in our network configuration

echo -e "127.0.0.1\t\tlocalhost" >> /etc/hosts
echo -e "::1\t\tlocalhost" >> /etc/hosts
echo -e "127.0.0.1\t\t"$hostname".localdomain" >> /etc/hosts

# internet persistence

systemctl enable dhcpcd

# installing the bootloader

if [[ -z "$BOOTLOADER" || "$BOOTLOADER" == "FALSE" ]]; then
        echo "[+] Not installing the bootloader"
else
        pacman -Sy --noconfirm grub efibootmgr dosfstools os-prober mtools

        # EFI bootloader

        grub-install --target=x86_64-efi --bootloader-id=grub --efi-directory=/boot
        grub-mkconfig -o /boot/grub/grub.cfg
fi

# create initial ramdisk environment to load kernel modules

mkinitcpio -p linux

## BASE INSTALL COMPLETE ##

## DESKTOP ENVIRONMENT INSTALL BEGIN ##

# Generate builduser

useradd -s /bin/bash builduser -m 
passwd -d builduser
make_root builduser

# Generate my user

# Some cleanup and editing of sudoers file

pacman -S --needed --noconfirm sudo git dialog python zsh cmake wget findutils
[[ -f /var/lib/pacman/db.lck ]] && rm /var/lib/pacman/db.lck  
sed -i 's/builduser.*//g;s/'$user'.*//g' /etc/sudoers
create_user "$user"
make_root "$user"

# Build YAY from source

sudo -u builduser bash -c "git clone https://aur.archlinux.org/yay.git /home/builduser/yay && cd /home/builduser/yay && makepkg -si --noconfirm && cd .. && rm -rf yay"

# Configure the desktop manager

pacman -Sy --noconfirm xorg-server lightdm lightdm-gtk-greeter cinnamon noto-fonts
sudo -u builduser bash -c "yay -Sy --noconfirm lightdm-slick-greeter"
sed -i 's/#greeter-session=.*/greeter-session=lightdm-slick-greeter/' /etc/lightdm/lightdm.conf
systemctl enable lightdm.service
wget "https://raw.githubusercontent.com/JaredDyreson/dotfiles/master/desktop_env/slick-greeter.conf" -O /etc/lightdm/slick-greeter.conf
wget "https://raw.githubusercontent.com/JaredDyreson/Thin-Mint/master/wallpapers/VenomWallpaper.jpg" -O /etc/lightdm/venom_wallpaper.jpg

# Grab compiled themes

find "$PKG_SRC/themes" -type f -exec pacman -U {} \;
pacman -Sy --noconfirm flat-remix-gnome

# Install GUI Applications

pacman -Sy --noconfirm vlc zenity firefox htop bluez blueman file-roller xreader virtualbox gedit
find "$PKG_SRC/gui_applications" -type f -exec pacman -U {} \;

# Configure Firefox

cp -ar --no-preserve=mode "$EXT_BASE/firefox_data/*" /home/"$USER"/.mozilla/
chown -R "$user":users /home/"$USER"/.mozilla

## PROGRAMMING ENVIRONMENT BEGIN ##

# C++, Java, LaTeX, Pandoc

pacman -Sy --noconfirm clang most jre-openjdk jdk-openjdk openjdk-doc python-pip texlive-most pandoc pdfgrep
# man pages for std:: functions
cd /tmp && git clone https://github.com/jeaye/stdman.git && cd stdman && ./configure && make install && mandb && cd .. && rm -rf stdman

sudo -u "$user" bash -c "git clone https://github.com/JaredDyreson/scripts.git /home/"$user"/scripts"
sudo -u "$user" bash -c "git clone https://github.com/JaredDyreson/starbucks_automa_production.git /tmp"
pip3.8 install --upgrade google_auth_oauthlib google-api-python-client termcolor selenium
