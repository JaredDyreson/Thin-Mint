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
boot_drive="$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tail -n 1 | awk '{print $1}')"
timedatectl set-ntp true

# Partitioning the drives

## EFI Partition
(echo "n" && echo "p" && echo "" && echo "" && echo "1002048" && echo "a" && echo "t" && echo "ef" && echo "w") | fdisk "$boot_drive" 

## Rest of the install

(echo "n" && echo "p" && echo "" && echo "" && echo "" && echo "w") | fdisk "$boot_drive" 

# Formatting the drive
partitions="$(sudo sfdisk -l | awk '/^\/dev/ {print $1}' | grep "$boot_drive")"
mkfs.vfat -F32 "$(sed -n '1p' <<< "$boot_drive")" 
mkfs.ext4 "$(sed -n '2p' <<< "$boot_drive")" 

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
pacman -Sy --noconfirm grub efibootmgr ipw2200-fw lshw
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# internet persistance
systemctl enable dhcpcd


# Pull script for installing desktop (currently in development and only calls one function)

#curl -sL https://git.io/fjwVT | bash

# Final cleanup
umount /mnt/*
exit
reboot
