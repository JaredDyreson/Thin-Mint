#!/bin/sh

# Very helpful video --> https://www.youtube.com/watch?v=UzESH4KK8qs&t=2294s

TGTDEV="$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tail -n 1 | awk '{print $1}')"

`timedatectl set-ntp true`

# Partitioning the drives

# link to this code -> https://superuser.com/questions/332252/how-to-create-and-format-a-partition-using-a-bash-script

# to create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk
# The sed script strips off all the comments so that we can 
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "defualt" will send a empty
# line terminated with a newline to take the fdisk default.
#sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk "${TGTDEV}"
  #o # clear the in memory partition table
  #n # new partition
  #p # primary partition
  #1 # partition number 1
    ## default - start at beginning of disk 
  #+100M # 100 MB boot parttion
  #n # new partition
  #p # primary partition
  #2 # partion number 2
    ## default, start immediately after preceding partition
    ## default, extend partition to end of disk
  #a # make a partition bootable
  #1 # bootable partition is partition 1 -- /dev/sda1
  #p # print the in-memory partition table
  #w # write the partition table
  #q # and we're done
#EOF

sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk "${TGTDEV}"
  o # clear the in memory partition table
  n
  p


  +100M
  a
  t
  ef
  w
  n
  p



  w

EOF

exit

# Formatting the drive

partitions="$(sudo sfdisk -l | awk '/^\/dev/ {print $1}')"
boot=`sed -n '1p' <<< "$partitions"`
primary=`sed -n '2p' <<< "$partitions"`
mkfs.vfat -F32 "$boot"
mkfs.ext4 "$primary"

## Mounting our filesystems

mkdir -p /mnt/boot
mount "$boot" /mnt/boot
mount "$primary" /mnt

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

curl -sL https://git.io/fjwVT | bash

## Final cleanup
exit
umount /mnt/
reboot
