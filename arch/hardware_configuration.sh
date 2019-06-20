#!/usr/bin/env bash 

# Here we are configuring the hardware to act the way we need it to

# CHECK IF WE ARE OUR DELL XPS LAPTOP #

[[ "$(sudo lshw -C system | awk '/product/ {$1="";print $0}' | grep -i "xps")" || $(sudo lshw -C system | awk '/description/ {$1="";print $0}' | grep -i "notebook") ]] || (echo "Not the laptop, exiting";exit)



## Trackpad

pacman -Sy --noconfirm xf86-input-libinput libinput libinput-gestures xdotool

# put the configuration we want directly from the dotfiles repo
find /usr/share/X11/xorg.conf.d/ -type f -iname '*libinput.conf' | while read line; do
	cat /tmp/dotfiles/trackpad/libinput.conf > "$line"
done
sudo gpasswd -a jared input
libinput-gestures-setup autostart
cp /tmp/dotfiles/trackpad/libinput-gestures.conf /home/jared/.config/libinput-gestures.conf


## Battery

pacman -Sy --noconfirm tlp
sudo systemctl enable tlp.service
sudo systemctl enable tlp-sleep.service

## Configure Graphics Card

### This should be done at the very end!

pacman -Sy --noconfirm acpi acpi_call-dkms
echo '_SB.PCI0.PEG0.PEGP._OFF' | sudo tee /proc/acpi/call
sudo echo acpi_call > /etc/modules-load.d/acpi_call.conf
cp -ar /tmp/dotfiles/graphics/dgpu-off.service /usr/lib/systemd/user/
sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/s/".*"/"quiet splash modprobe.blacklist=nouveau i915.preliminary_hw_support=1 acpi_rev_override=5"/' /etc/default/grub
sudo update-grub
reboot

