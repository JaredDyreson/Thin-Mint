#!/usr/bin/env bash

# Installer for Arch Linux so I never have to touch an installer ever again

# First half was copied from here -> https://disconnected.systems/blog/archlinux-installer/#the-complete-installer-script
# Second half was copied from here -> https://github.com/MatMoul/archfi/blob/master/archfi
# This is a link shortener -> https://git.io/

# USER CONFIGURATION #

set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

### Get infomation from user ###

hostname="jared-xps"
user="jared"

password=$(dialog --stdout --passwordbox "Enter admin password" 0 0) || exit 1
clear
: ${password:?"password cannot be empty"}
password2=$(dialog --stdout --passwordbox "Enter admin password again" 0 0) || exit 1
clear
[[ "$password" == "$password2" ]] || ( echo "Passwords did not match"; exit 1; )


# where are we installing the bloody thing
devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac)
device=$(dialog --stdout --menu "Select installation disk" 0 0 0 ${devicelist}) || exit 1
### Set up logging ###
exec 1> >(tee "stdout.log")
exec 2> >(tee "stderr.log")

timedatectl set-ntp true

### Setup the disk and partitions ###
swap_size=$(free --mebi | awk '/Mem:/ {print $2}')
swap_end=$(( $swap_size + 129 + 1 ))MiB

parted --script "${device}" -- mklabel gpt \
  mkpart ESP fat32 1Mib 129MiB \
  set 1 boot on \
  mkpart primary linux-swap 129MiB ${swap_end} \
  mkpart primary ext4 ${swap_end} 100%

# Simple globbing was not enough as on one device I needed to match /dev/mmcblk0p1
# but not /dev/mmcblk0boot1 while being able to match /dev/sda1 on other devices.
part_boot="$(ls ${device}* | grep -E "^${device}p?1$")"
part_swap="$(ls ${device}* | grep -E "^${device}p?2$")"
part_root="$(ls ${device}* | grep -E "^${device}p?3$")"

mkfs.vfat -F32 "${part_boot}"
mkswap "${part_swap}"
mkfs.ext4 "${part_root}"
swapon "${part_swap}"

mount "${part_root}" /mnt
mkdir /mnt/boot
mount "${part_boot}" /mnt/boot

echo 'Server = http://mirrors.kernel.org/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel vim
echo "${hostname}" > /mnt/etc/hostname
genfstab -U /mnt >> /mnt/etc/fstab
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf

arch-chroot /mnt

# Configuring the user #

useradd -mU -s /usr/bin/zsh -G wheel "$user"
echo "$user:$password" | chpasswd --root /mnt
echo "root:$password" | chpasswd --root /mnt

# Misc #

ln -sf /usr/share/timezone/America/Los_Angeles /etc/localtime
hwclock --systohc
locale-gen

# For networking #
pacman -S networkmanager
systemctl enable NetworkManager

## GRUB ##
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --recheck
grub-install --target=i386-pc --recheck /dev/sda
exit
reboot
