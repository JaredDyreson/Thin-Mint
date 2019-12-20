#!/bin/sh

# Very helpful video --> https://www.youtube.com/watch?v=UzESH4KK8qs&t=2294s

TGTDEV="$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tail -n 1 | awk '{print $1}')"
MEMTOTAL="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"

`timedatectl set-ntp true`

# Partitioning the drives

# link to this code -> https://superuser.com/questions/332252/how-to-create-and-format-a-partition-using-a-bash-script

sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk "${TGTDEV}"
  o # clear the in memory partition table
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

efi=""$TGTDEV"1"
swap=""$TGTDEV"2"
filesystem=""$TGTDEV"3"

mkfs.vfat -F32 "$efi"
mkfs.ext4 "$filesystem"

## Mounting our filesystems

mkdir -p /mnt/boot
mount "$efi" /mnt/boot
mount "$filesystem" /mnt

## Working with the mounted partitions

pacstrap /mnt base base-devel

genfstab -U /mnt > /mnt/etc/fstab

arch-chroot /mnt

## Set the correct time zone

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
pacman -Sy --noconfirm grub efibootmgr ipw2200-fw lshw
grub-install "$TGTDEV"
grub-mkconfig -o /boot/grub/grub.cfg

## internet persistance
systemctl enable dhcpcd

## Pull script for installing desktop (currently in development and only calls one function)

#curl -sL https://git.io/fjwVT | bash

## Final cleanup
exit
umount /mnt/
reboot
