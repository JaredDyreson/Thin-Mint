#!/bin/sh

# installer script for Arch Linux (1/3)
# task: setup partitions, install base packages and install a bootloader (GRUB)
# AUTHOR: Jared Dyreson, CSUF 2021

timedatectl set-ntp true

# Partition names

# base disk

TGTDEV="$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tail -n 1 | awk '{print $1}')"

# sub partitions

efi=""$TGTDEV"1"
swap=""$TGTDEV"2"
root=""$TGTDEV"3"
home_dir=""$TGTDEV"4"

# action of partitioning

sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk "${TGTDEV}"
  d
  1
  d
  2
  d
  3
  d
  4
  g # GPT partition table
  n
  1
   
  +512M
  n
  2

  +4G
  n
  3
   
  +30G
  n
  4

  
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

# add w back to see if it worked

mkfs.vfat -F32 "$efi"
mkswap "$swap"
swapon "$swap"
mkfs.ext4 "$root"
mkfs.ext4 "$home_dir"

mount "$root" /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount "$efi" /mnt/boot
mount "$home_dir" /mnt/home

pacstrap /mnt base base-devel linux linux-firmware sysfsutils usbutils e2fsprogs netctl device-mapper cryptsetup vim man-db man-pages inetutils dhcpcd s-nail intel-ucode

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

hwclock --systohc --utc

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

hostname="jared-xps"
echo "$hostname" > /etc/hostname

echo -e "127.0.0.1\t\tlocalhost" >> /etc/hosts
echo -e "::1\t\tlocalhost" >> /etc/hosts
echo -e "127.0.0.1\t\t"$hostname".localdomain"  $hostname"" >> /etc/hosts

systemctl enable dhcpcd

pacman -Sy --noconfirm grub efibootmgr dosfstools os-prober mtools

if [[ "$(efibootmgr | grep "are not supported")" ]]; then
        
        echo "[+] installing BIOS version of GRUB"
else
        echo "[+] installing EFI version of GRUB"
fi

grub-install --target=x86_64-efi --bootloader-id=grub --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -p linux
#curl -sL https://git.io/fjwVT | bash
exit
umount /mnt/boot
umount /mnt

#reboot

