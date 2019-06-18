#!/usr/bin/env bash

# mintyrice : written by Jared Dyreson (use as you please license. if you break your install, figure it out)

# TODO
# 1. Install zsh and make that the default shell
# 2. Install vim and make that the default editor
# 3. Add in custom keyboard shortcuts (map CAPS LOCK to escape)
# 4. Install custom scripts to appropriate folder
# 5. Remove unecessary programs that I find to be bloat
# 6. Install clang++ in replacement of g++
# 7. Install Flat-Remix theme
# 8. Decide to continue using gnome-terminal or move over to st (suckless termnial)
# 9. Disable GPU via a kernel edit
# 10. Deploy all Github repositories in $HOME/Projects
# 11. Fix battery life issues with the given function we already have
# 12. Trackpad fix (see if I can make it less sensitive because of links being opened by fingertips too much)
# 13. Install ranger

# This is split into two parts
## 1. Get all initial programs installed that we can before we

function find_program() {
	[[ $(dpkg --list | awk '/'$1'/ {print $2}') ]] && return true || return false
}

function default_shell() {

}

function default_editor() {

	[[  "$EDITOR" !=  "vim" ]] && (sed -i "/export\ EDITOR/s/'.*'/'vim'/" "$HOME"/.zshrc) || echo "[+] vim is the default editor"
}

function git_setup() {

	git config --global user.name "Jared Dyreson"
	git config --global user.email "jared.dyreson@gmail.com"
}
function key_mappings() {

	git_setup
	# map caps lock to escape permanently
	setxkmap -option caps:swapescape
	# here we will just load all of the settings for the desktop, much easier to maintain than having individual files floating around
	# this should be called at the end, when theme, spotify, discord, and other desktop apps have been installed because there might be some errors that would occur (untested at this point, might be harmless)
	[[ -d "/tmp/dotfiles" ]] && (dconf load / < /tmp/dotfiles/desktop_env/cinnamon_settings) || (get_minty_repo && dconf load / < /tmp/dotfiles/desktop_env/cinnamon_settings)
}

function install_desktop_apps() {
	# discord
	wget -O discord.deb "https://discordapp.com/api/download?platform=linux&format=deb" && sudo dpkg -i discord.deb && rm discord.deb
	# spotify
	sudo apt-get install "gnupg2" -y
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886 -y
	echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
	[[ $(grep "deb http://security.debian.org/debian-security wheezy/updates main" /etc/apt/sources.list) ]] && (continue) || sudo echo "deb http://security.debian.org/debian-security wheezy/updates main" >> /etc/apt/sources.list
	sudo apt-get update && sudo apt-get install "libssl1.0.0" spotify-client -y
}

function configure_desktop_appearence() {

}

function install_custom_scripts() {
	git_setup
	cd ~ && git clone https://github.com/JaredDyreson/scripts.git
}


function configure_desktop() {
	install_desktop_apps
	# remove clutter 
	sudo apt-get remove hexchat hexchat-common tomboy gstreamer1.0-packagekit transmission-gtk transmission-common thunderbird thunderbird-gnome-support thunderbird-locale-en thunderbird-locale-en-us xplayer xplayer-common xplayer-dbg xplayer-plugins rhythmbox rhythmbox-data rhythmbox-plugin-tray-icon rhythmbox-plugins gir1.2-rb-3.0:amd64 -y 
	
}

function get_minty_repo() {
	git_setup
	cd /tmp
	git clone https://github.com/JaredDyreson/mintyrice.git
	git clone https://github.com/JaredDyreson/dotfiles.git
}

function install_clang() {
	wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -y -
	sudo apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-6.0 main" -y
	sudo apt-get update
	sudo apt-get install clang++-6.0 -y 
}

function install_cpp_man_pages() {
	git_setup
	cd /tmp && git clone https://github.com/jeaye/stdman.git && cd stdman && ./configure && sudo make install
}


function configure_trackpad() {
	sudo apt-get remove xserver-xorg-input-synaptics-hwe-16.04 -y
	sudo apt-get install xserver-xorg-input-libinput-hwe-16.04 libinput-tools xdotool -y
	# put the configuration we want directly from the dotfiles repo
	find /usr/share/X11/xorg.conf.d/ -type f -iname '*libinput.conf' | while read line; do
		cat /tmp/dotfiles/trackpad/libinput.conf > "$line"
	done
	git clone http://github.com/bulletmark/libinput-gestures && cd libinput-gestures && sudo make install && cd .. && rm -rf libinput-gestures
	sudo gpasswd -a "$USER" input
	libinput-gestures-setup autostart
	cp /tmp/dotfiles/trackpad/libinput-gestures.conf ~/.config/libinput-gestures.conf
}

function configure_graphics() {
	sudo apt-get install acpi acpi-call-dkms -y
	echo '_SB.PCI0.PEG0.PEGP._OFF' | sudo tee /proc/acpi/call
	sudo echo acpi_call > /etc/modules-load.d/acpi_call.conf
	cp -ar /tmp/dotfiles/graphics/dgpu-off.service /usr/lib/systemd/user/
	sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/s/".*"/"quiet splash modprobe.blacklist=nouveau i915.preliminary_hw_support=1 acpi_rev_override=5"/' /etc/default/grub
	sudo update-grub
	reboot
}

get_minty_repo
# rewrite

function installer(){
	# upgrade packages (takes a while)
	sudo apt-get update && sudo apt-get upgrade -y
	# install vim and zsh
	sudo apt-get install vim zsh -y
	# install git and configure it
	sudo apt-get install git -y
	git config --global user.name "Jared Dyreson"
        git config --global user.email "jared.dyreson@gmail.com"
	# Install C++ Environment
	cd /tmp && git clone https://github.com/jeaye/stdman.git && cd stdman && ./configure && sudo make install
	sudo mandb
	sudo apt-get install clang++-6.0 -y
	# install latex

}
