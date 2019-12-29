#!/usr/bin/env bash

# Task: scripts to be run inside a arch-chroot environment

# secondary component to the base installer  (2/4)
# task: run setup inside of the arch-chroot environment
# AUTHOR: Jared Dyreson, CSUF 2021

# timezone

ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

# sync the time

hwclock --systohc --utc

# we want English as primary language

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# what is our machine's name to the world

hostname="jared-xps"
echo "$hostname" > /etc/hostname

# make sure this name is reflected in our network configuration

echo -e "127.0.0.1\t\tlocalhost" >> /etc/hosts
echo -e "::1\t\tlocalhost" >> /etc/hosts
echo -e "127.0.0.1\t\t"$hostname".localdomain" >> /etc/hosts

# internet persistence

systemctl enable dhcpcd

# installing the bootloader

if [[ -z "$BOOTLOADER" ]]; then
        echo "[+] Not installing the bootloader"
else

        pacman -Sy --noconfirm grub efibootmgr dosfstools os-prober mtools

        # EFI bootloader

        grub-install --target=x86_64-efi --bootloader-id=grub --efi-directory=/boot
        grub-mkconfig -o /boot/grub/grub.cfg
fi

# compile the kernel

mkinitcpio -p linux
