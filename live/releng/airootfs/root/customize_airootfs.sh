#!/bin/bash

set -e -u

# timezone

ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc --utc

usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/
chmod 700 /root
# unset the root password
passwd -d root

sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf

systemctl enable pacman-init.service choose-mirror.service systemd-networkd.service systemd-resolved.service NetworkManager
systemctl set-default multi-user.target
