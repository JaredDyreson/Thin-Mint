# CSUF WiFi Setup

## Arch Linux

First, please have `NetworkManager` installed.
This can be done using the following command:

```bash
sudo pacman -Sy --noconfirm networkmanager xorg-xwininfo
```

Follow [this link](http://wireless.fullerton.edu/eduroam/) to grab the WiFi wizard and click "CSUF Student".

Once that's done, change its permissions to execute and run it.
Provide the proper credentials and it will configure itself.

```bash 
chmod +x ~/Downloads/SecureW2_JoinNow.run
~/Downloads/SecureW2_JoinNow.run
```

Follow the prompt and then you're connected.

## Debugging

If there are any issues, you can decompile the executable `.run` file by using `binwalk`.

```bash
sudo pacman -Sy --noconfirm binwalk
```

Decompile with the following command:

```bash
binwalk -e ~/Downloads/SecureW2_JoinNow.run
mkdir eduroam_installer
tar -xf ./_SecureW2_JoinNow.run.extracted/SecureW2_JoinNow.tar -C eduroam_installer
rm -rf ./_SecureW2_JoinNow.run.extracted/
python eduroam_installer/main.py
```

You can also use the flags below to get some more verbose output:

```
--interpreter-detect
--verbose-detect
--verbose-detect-external
--verbose-detect-all
--backtrace
--backtrace-all
```

If

**Note:** NetworkManager stores its connection in the directory: `/etc/NetworkManager/system-connections/`

