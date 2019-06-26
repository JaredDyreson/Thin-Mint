# Desktop

## User space Functions

### make_root

Give the supplied user root access to the machine

### password_manager

Ask for password input until both passwords are the same. Change the current password for a given user and store it in a temporary file in the home directory.

### check_user

Check for the presence of a given user, returning true if they have been found in /etc/passwd and false otherwise.

### create_user

Instantiate a user given a name with the correct folder structure and projects

### initial_configuration

Make sure the builduser is present and removes any potential roadblocks the script may encounter during installation. It also installs yay, git, sudo, dialog, python and zsh which are all tools used during the install process. The builduser is also created during this function and is basically another sudo. `makepkg` will refuse to even run when root is running so we need to create another.


## Installation Functions

### terminal_configuration

Configure the terminal to prettify zsh and vim. We also install our terminal emulator of choice, `urxvt`, along with the proper fonts.

![alt text](assets/terminal_output)

### desktop_manager

The main concern here is getting the graphical environment ready for login after the first reboot. `xorg-server` is a package that will allow us to manage one or more displays that have peripherals such as mice, keyboards and microphones attached to them. This is a base for the next package `lightdm` will attach itself to. This is a desktop manager, which will help facilitate the processes of a desktop environment. Before proceeding to the next step it is important to enable the service in which lightdm runs as so we don't have to manually start it every time we boot.As it stands right now, we have no graphical way of logging into the system, so we need a greeter which will graphically ask us for our password and allow us to access the last bit of software, the desktop environment. The default greeter is not set so we can directly edit the configuration file with `sed`, which stands for streamline editor. We are now free to choose how our desktop looks by installing various different window managers but in our case we will just stick with Cinnamon because it familiar to us.

Current Desktop

![alt text](assets/current_desktop)

Desktop after installer

![alt text](assets/installer_desktop)

# External Links

[Fixing ZSH Icons](https://unix.stackexchange.com/questions/429946/zsh-icons-broke-in-urxvt)

[Font Settings for Panel](https://forums.linuxmint.com/viewtopic.php?t=106758)
