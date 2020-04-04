# iPhone Support

To set up support for your iDevice, please run these commands:

```bash
./iphone_support
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

## Create backups

```bash
mkdir ~/Documents/iPhoneBackups
idevicebackup2 backup --full ~/Documents/iPhoneBackups
```

If you want the backup to be more browse-able, run the following command:

```bash
idevicebackup2 unback ~/Documents/iPhoneBackups/
```

# External Links

- [Original FOSS Article](https://itsfoss.com/iphone-antergos-linux/)
- [Github thread that helped fix lockdownd issue](https://github.com/libimobiledevice/ifuse/issues/39)
- [Original Arch Linux Manual Page](https://wiki.archlinux.org/index.php/User:Lekensteyn/Upgrading_iOS)
- [Browse iPhone Backup](https://santoku-linux.com/howto/mobile-forensics/howto-create-a-logical-backup-of-an-ios-device-using-libimobiledevice-on-santoku-linux/)
