#!/bin/sh

# Very helpful video --> https://www.youtube.com/watch?v=UzESH4KK8qs&t=2294s
function install_git_package() {
	waypoint="$(pwd)"
	for repo in "$@"; do
		[[ "$(curl -Is git clone "$repo" 2> /dev/null | head -n 1 | grep -i "ok")" || -z "$repo" ]] || (echo "Link cannot be reached, cowardly refusing" && break)
		go_here="$(basename "$repo" | sed 's/\.git//g')"
		#git clone "$repo" && cd "$go_here"
		runuser -l jared -c 'cd /home/jared && git clone '$1' && cd '$go_here' && makepkg -si --noconfirm && cd .. && rm -rf '$go_here''
	done
}

timedatectl set-ntp true

# Partitioning the drives

## EFI Partition
(echo "n" && echo "p" && echo "" && echo "" && echo "1002048" && echo "a" && echo "t" && echo "ef" && echo "w") | fdisk /dev/sda

## Rest of the install

(echo "n" && echo "p" && echo "" && echo "" && echo "" && echo "w") | fdisk /dev/sda

# Formatting the drive

mkfs.vfat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

# Mounting our filesystems

`cd /mnt && mkdir boot`
mount /dev/sda1 /mnt/boot
mount /dev/sda2 /mnt

echo "PARTITIONS MOUNTED"

# Working with the mounted partitions

echo "INSTALLING DEVELOPMENT TOOLS"
pacstrap /mnt base base-devel
#exit 
genfstab -U /mnt > /mnt/etc/fstab

arch-chroot /mnt

# Set the correct time zone

ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

# Get our locales

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set the hostname and hostfiles
hostnamed="jared-xps"
echo "$hostnamed" > /etc/hostname
echo "127.0.0.1 localhost $hostnamed" > /etc/hosts

# Working with GRUB
pacman -Sy --noconfirm grub efibootmgr ipw2200-fw
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# internet persistance
systemctl enable dhcpcd


# Pull script for installing desktop (currently in development and only calls one function)

curl -sL https://git.io/fjwVT | bash

# Final cleanup
umount /mnt/*
exit
reboot
