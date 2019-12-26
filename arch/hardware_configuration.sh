#!/usr/bin/env bash 

# Here we are configuring the hardware to act the way we need it to

# CHECK IF WE ARE OUR DELL XPS LAPTOP 

[[ "$(sudo lshw -C system | awk '/product/ {$1="";print $0}' | grep -i "xps")" || $(sudo lshw -C system | awk '/description/ {$1="";print $0}' | grep -i "notebook") ]] || (echo "Not the laptop, exiting";exit) && (echo "We can proceed")

sleep 10

## Trackpad

pacman -Sy --noconfirm xf86-input-libinput libinput libinput-gestures xdotool

# put the configuration we want directly from the dotfiles repo
find /usr/share/X11/xorg.conf.d/ -type f -iname '*libinput.conf' | while read file; do
	cat /home/"$user"/Projects/dotfiles/trackpad/libinput.conf > "$file"
done
sudo gpasswd -a "$user" input
libinput-gestures-setup autostart
echo "[+] Libinput gestures service started"
sleep 10
cp /home/"$user"/Projects/dotfiles/trackpad/libinput-gestures.conf /home/"$user"/.config/libinput-gestures.conf


## Battery

pacman -Sy --noconfirm tlp nvme-cli
sudo systemctl enable tlp.service
sudo systemctl enable tlp-sleep.service
echo "[+] Enabling TLP Services"

## Configure Graphics Card

### This should be done at the very end!

pacman -Sy --noconfirm linux-headers
pacman -Sy --noconfirm acpi acpi_call-dkms
modprobe acpi_call
echo '_SB.PCI0.PEG0.PEGP._OFF' | sudo tee /proc/acpi/call
echo acpi_call > /etc/modules-load.d/acpi_call.conf
cp -ar /home/"$user"/Projects/dotfiles/graphics/dgpu-off.service /usr/lib/systemd/user/
sudo systemctl enable /usr/lib/systemd/user/dgpu-off.service
sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/s/".*"/"modprobe.blacklist=nouveau i915.preliminary_hw_support=1 acpi_rev_override=5"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg


# if the device is the desktop

function disable_pc_speaker(){
	rmmod pcspkr
	echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf
}
