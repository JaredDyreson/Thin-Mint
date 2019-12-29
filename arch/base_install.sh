#!/bin/sh

# installer script for Arch Linux (1/4)
# task: setup partitions, internet, and install base packages 
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

# make the EFI partition, swap (enable as well), root and user partitions
mkfs.vfat -F32 "$efi"
mkswap "$swap"
swapon "$swap"
mkfs.ext4 "$root"
mkfs.ext4 "$home_dir"

# mount and make new partitions
mount "$root" /mnt
mkdir /mnt/boot
mkdir /mnt/home
mount "$efi" /mnt/boot
mount "$home_dir" /mnt/home

# internet

# check if the script is running inside a VM

if [[ "$(grep "hypervisor" /proc/cpuinfo)" ]]; then
        echo "[+] Using builtin wifi for VM"
else
        wifi_device_id="$(basename $(ls -d /sys/class/net/w*))"
        systemctl enable netctl-auto@"$wifi_device_id".service
        wifi-menu -o
fi

# install the bare minimum packages

pacstrap /mnt base base-devel linux linux-firmware sysfsutils usbutils e2fsprogs netctl device-mapper cryptsetup vim man-db man-pages inetutils dhcpcd s-nail intel-ucode

# setup fstab so we know where we can boot from

genfstab -U /mnt >> /mnt/etc/fstab

# setup secondary component to the script

curl -sL https://git.io/ > /mnt/chroot_env.sh
chmod +x /mnt/chroot_env.sh

arch-chroot /mnt /mnt/chroot_env.sh
exit

# we no longer need these components

umount /mnt/boot
umount /mnt/home
umount /mnt/
