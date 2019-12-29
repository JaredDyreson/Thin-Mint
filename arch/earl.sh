#!/usr/bin/env bash

# Task: build and capture compiled binary installer package via yay
# example how to run: sudo -u "$USER" bash -c "./earl.sh [PKG NAME]"

DST="/run/media/jared/External/compiled_arch_binaries/yay_compiled/"
SRC="/home/$USER/.cache/yay"

# check if we're root and have correct permissions

#[[ "$EUID" -ne 0 ]] && exit 1

# is the drive connected? 

[[ ! -b "/dev/sda" || ! -d "$DST" ]] && exit 1

# are we given any arguments? 

#[[ -z "$@" ]] && exit 2

declare -a packages=('lightdm-slick-greeter' 'mint-x-icons' 'mint-y-icons' 'mint-themes' 'ffmpeg-compat-57' 'shutter' 'discord' 'balena-etcher' 'mintstick' 'pix')


for pkg in "${packages[@]}"; do
        echo "[+] Queuing $pkg...."
        yay -Syw --nocleanafter --needed --noconfirm "$pkg"
        find "$SRC" -type f -name '*.tar.xz' -exec sudo cp {} "$DST" \;
        sudo chown -R "$USER" "$DST"
done

# RUNNING LIST OF PKGS NEEDED
#lightdm-slick-greeter
#mint-x-icons
#mint-y-icons 
#mint-themes
#ffmpeg-compat-57
#shutter
#discord
#balena-etcher
#mintstick
#pix
