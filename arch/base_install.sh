#!/bin/sh

# installer script for Arch Linux
# task: setup partitions, install base packages and install a bootloader (GRUB)
# AUTHOR: Jared Dyreson, CSUF 2021

TGTDEV="$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tail -n 1 | awk '{print $1}')"
WIRELESS_CARD_NAME="$(sudo lshw -class network | awk '/logical name/ {print $3}' 2> /dev/null)"
#PARTITION_TABLE="$(lsblk -plnx type -o name,type | awk '/part/ {print $1}' | sort)"
#counter=1
#echo "$PARTITION_TABLE" | while read partition; do
        #sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk "${TGTDEV}"
        #o
        #d
        #'$counter'
#EOF
#counter=$((counter+1))
#done

MEMTOTAL="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"

efi=""$TGTDEV"1"
swap=""$TGTDEV"2"
filesystem=""$TGTDEV"3"

`timedatectl set-ntp true`

# Partitioning the drives

sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk "${TGTDEV}"
  o # clear the in memory partition table
  d
  1
  d
  2
  d
  3
  n # new partition
  p # primary
  1 # first one
  2048 # default
  +512MB # how big
  a # toggle bootable flag (automaticaly chooses this one)
  t # change parition type
  ef # EFI
  n # new partition
  p # primary
  2 # second one

  +5GB # swap size
   # default
  t # change parition type
  2 # select the second partition
  82 # swap identifier
  n # new partition
  p # primary
  3 # third partition
   # default
   # default
  w
EOF

# Formatting the drive

mkfs.vfat -F32 "$efi"
mkswap "$swap"
swapon "$swap"
mkfs.ext4 "$filesystem"

## Mounting our filesystems

sudo mkdir -p /mnt/boot/efi
mount "$filesystem" /mnt

## Working with the mounted partitions

pacstrap /mnt base base-devel

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

# we need to re run this because we change our shell

TGTDEV="$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tail -n 1 | awk '{print $1}')"

## Set the correct time zone

hwclock --systohc --utc

ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

## Get our locales

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

## Set the hostname and hostfiles

hostname="jared-xps"
echo "$hostname" > /etc/hostname
echo "127.0.0.1 localhost $hostname" > /etc/hosts

## Working with GRUB
pacman -Sy --noconfirm grub efibootmgr ipw2200-fw lshw intel-ucode os-prober
mount "$efi" /boot/efi
grub-install --boot-directory=/mnt/boot --bootloader-id=arch_grub  --target=x86_64-efi --efi-directory=/mnt/boot/efi  
grub-mkconfig -o /boot/grub/grub.cfg

## internet persistance
systemctl enable dhcpcd

## Pull script for installing desktop (currently in development and only calls one function)

#curl -sL https://git.io/fjwVT | bash

## Final cleanup
exit
umount -a
umount /mnt/boot
reboot
