# iPhone Support

To set up support for your iDevice, please run these commands:

```bash
sudo pacman -Sy ifuse usbmuxd libplist libimobiledevice
mkdir ~/iPhone
reboot
```

You can confirm it with typing in the following command after a reboot:

```bash
dmesg | grep -i 'iphone\|ipad\|ipod'
```

Once you reboot, you should have the ability to interface with an iDevice plugged in.
This requires you to fill in the passcode asking if you trust the laptop/computer you are attached to.
Please also properly pair a given device to computer you are using, if not you will run into `lockdownd` errors.

Run the following command to ensure your iDevice is paired with the computer:

```bash
idevicepair pair
```

# External Links

- [Original FOSS Article](https://itsfoss.com/iphone-antergos-linux/)
- [Github thread that helped fix lockdownd issue](https://github.com/libimobiledevice/ifuse/issues/39)
- [Original Arch Linux Manual Page](https://wiki.archlinux.org/index.php/User:Lekensteyn/Upgrading_iOS)
