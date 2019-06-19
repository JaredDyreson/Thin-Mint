#!/bin/sh

# Very helpful video --> https://www.youtube.com/watch?v=UzESH4KK8qs&t=2294s

#timedatectl set-ntp true

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

echo "jared-xps" > /etc/hostname
echo "127.0.0.1 localhost jared-xps" > /etc/hosts


# not installed by default
pacman -Sy dialog

password=$(dialog --stdout --passwordbox "Enter admin password" 0 0)
[[ -z "$password" ]] && (echo "password seems to be empty";passwd)
password2=$(dialog --stdout --passwordbox "Enter admin password again" 0 0) || exit 1
[[ -z "$password2" ]] && (echo "password seems to be empty";passwd)
clear
[[ "$password" == "$password2" ]] || ( echo "Passwords did not match"; exit 1; )

#echo "root:$password" | chpasswd --root /mnt

# Working with 
pacman -Sy grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

umount /mnt/*
reboot
