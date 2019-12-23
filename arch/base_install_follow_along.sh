#!/bin/sh

# authors: Jared Dyreson and ufoludek

hostname="jared-xps"

timedatectl set-ntp true

# Partition names

# base disk

TGTDEV="$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tail -n 1 | awk '{print $1}')"

# sub partitions

efi=""$TGTDEV"1"
swap=""$TGTDEV"2"
filesystem=""$TGTDEV"3"

# action of partitioning


sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk "${TGTDEV}"
  g # GPT partition table
  n
  1
   
  +512M
  n
  2

  +4G
  n
  3
   

  t
  1
  1
  t
  2
  19
  t
  3
  24
  w
EOF

fdisk -l

mkfs.vfat "$efi"
mkswap "$swap"
swapon "$swap"
mkfs.ext4 "$filesystem"

mount "$filesystem" /mnt
mkdir /mnt/boot
mount "$efi" /mnt/boot

pacstrap /mnt base base-devel linux linux-firmware vim man-db man-pages inetutils dhcpcd s-nail intel-ucode

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

hwclock --systohc --utc

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "$hostname" > /etc/hostname

echo -e "127.0.0.1\t\tlocalhost" >> /etc/hosts
echo -e "::1\t\tlocalhost" >> /etc/hosts
echo -e "127.0.0.1\t\t"$hostname".localdomain\t\t"$hostname"" >> /etc/hosts

bootctl --path=/boot install
UUID_BOOT="$(blkid | grep ""$TGTDEV"3" | awk '{print $2}' | grep -o '".*"' | sed 's/"//g')"
echo "default arch-*" > /boot/loader/loader.conf
echo -e "title\tArch Linux" >> /boot/loader/entries/arch.conf
echo -e "linux\t/vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo -e "initrd\t/intel-ucode.img" >> /boot/loader/entries/arch.conf
echo -e "initrd\t/initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo -e "options\troot=UUID=$UUID_BOOT rw" >> /boot/loader/entries/arch.conf
