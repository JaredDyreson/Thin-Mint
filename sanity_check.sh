#!/usr/bin/env bash

# this is meant to be for automatic testing for Cubic/any chroot environment for a Linux Mint 18.2 install
# also should really be used with the actual physical machine, more or less treat this as documentation
# we have also installed a kernel that we know will work for our workflow

# TODO
# There should be three components to my backup solution
# 1. This custom ISO image that contains all of the packages, kernel hacks/upgrades and overall decluttering of the original ISO installer
# 2. Git repositories deployed to be synced in unision for one automatic push to the Github servers each night
# 3. Offsite backups of more personal photos, videos and other files/archives that need to be kept safe. This is currently in the form of an external hard drive but will be moved to a DAS (Direct Attached Storage) device make this a little more streamline and add redundancy.


# NOTE

# Changes made in the chroot environment can only be made with the root user, I have not tested to see if changes to other users (i.e) adding users and configuring their settings) will work right out of the box. The installer would still require you to have these steps to be completed so I don't see a point in making other edits in this regard

# Features include
# - Trackpad configuration (packages could be installed and then it can be configured in with a post install script)
# - installing and configuring user data (another script should handle the pulling and organizing)
	# git repos
	# maybe seeing if we can automatically download Spotify playlists to disk (something that is a nice to have but is completely NOT NECESSARY and can WAIT!)


sudo apt-get update
sudo apt-get upgrade -y

# install vim, zsh, ranger, git

sudo apt-get install vim zsh ranger git -y

# install CPSC tools

## CPP

### Clang
sudo apt-get install clang++-6.0 -y

### std::man_pages

cd /tmp && git clone https://github.com/jeaye/stdman.git && cd stdman && ./configure && sudo make install

## Java

sudo apt-get install openjdk-8-jdk openjdk-8-jre -y

## R

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 
sudo add-apt-repository -y 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/'
sudo apt-get update
sudo apt-get install r-base -y

# Desktop

## Remove unecessary programs (add to this if more are found, mostly meant to remove GUI based programs that serve no purpose to me, cutting down on space and overall cleanliness of the system)

sudo apt-get remove hexchat hexchat-common tomboy gstreamer1.0-packagekit transmission-gtk transmission-common thunderbird thunderbird-gnome-support thunderbird-locale-en thunderbird-locale-en-us xplayer xplayer-common xplayer-dbg xplayer-plugins rhythmbox rhythmbox-data rhythmbox-plugin-tray-icon rhythmbox-plugins gir1.2-rb-3.0:amd64 pidgin* -y 

## Applications

### Spotify

#wget -O spotify-client.deb "http://packages.linuxmint.com/pool/import/s/spotify-client/spotify-client_1.0.27.71.g0a26e3b2-9_amd64.deb"
#sudo dpkg -i spotify-client.deb

### Discord

wget -O discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
sudo apt-get install "libc++1" -y
sudo dpkg -i discord.deb

### Notable (Markdown Editor if needed)

# NOTE: This will be out of date when pulling because it is a hardcoded link

wget -O notable.deb "https://github.com/notable/notable/releases/download/v1.5.1/notable_1.5.1_amd64.deb"
sudo dpkg -i notable.deb


## Configuring the look of the desktop

### Load settings


### Keyboard Shortcuts


## Terminal

# grabbing some dependencies just in case

sudo apt-get install libfontconfig1-dev fontconfig libfreetype6-dev -y
cd /tmp
git clone https://github.com/JaredDyreson/dotfiles.git
#cd dotfiles/terminal/st*/
# sudo make install (this for some reason has been failing inside Cubic but it is not that big of a deal for me to worry about)


# fix the GPU settings

sudo apt-get install acpi acpi-call-dkms -y
echo '_SB.PCI0.PEG0.PEGP._OFF' | sudo tee /proc/acpi/call
sudo echo acpi_call > /etc/modules-load.d/acpi_call.conf
cp -ar /tmp/dotfiles/graphics/dgpu-off.service /usr/lib/systemd/user/
sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/s/".*"/"quiet splash modprobe.blacklist=nouveau i915.preliminary_hw_support=1 acpi_rev_override=5"/' /etc/default/grub
sudo update-grub

# fix the trackpad

# fix the battery life
sudo add-apt-repository ppa:linrunner/tlp
sudo apt-get update
sudo apt-get install tlp tlp-rdw -y

# FINISH BY updating the kernel

mkdir /tmp/build && cd /tmp/build
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.13/linux-headers-4.13.0-041300_4.13.0-041300.201709031731_all.deb
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.13/linux-headers-4.13.0-041300-generic_4.13.0-041300.201709031731_amd64.deb
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.13/linux-image-4.13.0-041300-generic_4.13.0-041300.201709031731_amd64.deb
sudo dpkg -i *.deb

# reboot

