#!/bin/sh

# installer script for Arch Linux (1/3)
# task: setup partitions, install base packages and install a bootloader (GRUB)
# AUTHOR: Jared Dyreson, CSUF 2021

function testing() {

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
}

testing


#TGTDEV="$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tail -n 1 | awk '{print $1}')"
##WIRELESS_CARD_NAME="$(sudo lshw -class network | awk '/logical name/ {print $3}' 2> /dev/null)"
##PARTITION_TABLE="$(lsblk -plnx type -o name,type | awk '/part/ {print $1}' | sort)"
##counter=1
##echo "$PARTITION_TABLE" | while read partition; do
        ##sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk "${TGTDEV}"
        ##o
        ##d
        ##'$counter'
##EOF
##counter=$((counter+1))
##done

#MEMTOTAL="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"

#efi=""$TGTDEV"1"
#swap=""$TGTDEV"2"
#filesystem=""$TGTDEV"3"

#`timedatectl set-ntp true`

## Partitioning the drives

#sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk "${TGTDEV}"
  #o # clear the in memory partition table
  #d
  #1
  #d
  #2
  #d
  #3
  #n # new partition
  #p # primary
  #1 # first one
  #2048 # default
  #+512MB # how big
  #a # toggle bootable flag (automaticaly chooses this one)
  #t # change parition type
  #ef # EFI
  #n # new partition
  #p # primary
  #2 # second one

  #+5GB # swap size
   ## default
  #t # change parition type
  #2 # select the second partition
  #82 # swap identifier
  #n # new partition
  #p # primary
  #3 # third partition
   ## default
   ## default
  #w
#EOF

## Formatting the drive

#mkfs.vfat -F32 -n "$efi"
#mkswap "$swap"
#swapon "$swap"
#mkfs.ext4 "$filesystem"

### Mounting our filesystems

#mount "$filesystem" /mnt
#sudo mkdir -p /mnt/boot
#mount "$efi" /mnt/boot

### Working with the mounted partitions

#pacstrap /mnt base base-devel grub-efi-x86_64 efibootmgr ipw2200-fw lshw intel-ucode os-prober

#genfstab -pU /mnt >> /mnt/etc/fstab

## THIS IS THE BREAK POINT FOR FOLLOW ALONG

#arch-chroot /mnt

## we need to re run this because we change our shell

#TGTDEV="$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tail -n 1 | awk '{print $1}')"

### Set the correct time zone

#hwclock --systohc --utc

#ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

### Get our locales

#echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
#locale-gen
#echo "LANG=en_US.UTF-8" > /etc/locale.conf

### Set the hostname and hostfiles

#hostname="jared-xps"
#echo "$hostname" > /etc/hostname
#echo "127.0.0.1 localhost $hostname" > /etc/hosts

### Working with GRUB

#mount ""$TGTDEV"1" /mnt/boot
#grub-install
#grub-mkconfig -o /boot/grub/grub.cfg

##if [[ "$(efibootmgr | grep "are not supported")" ]]; then
        ##echo "no UEFI"
##else
        ###mount "$efi" /mnt/boot/efi
        ###grub-install --boot-directory=/mnt/boot --bootloader-id=arch_grub  --target=x86_64-efi --efi-directory=/mnt/boot/efi  
##fi


### internet persistance
#systemctl enable dhcpcd

### Pull script for installing desktop (currently in development and only calls one function)

##curl -sL https://git.io/fjwVT | bash

### Final cleanup
#exit
