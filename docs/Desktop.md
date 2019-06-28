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


### theme_manager

Since we are building Arch with a bare Cinnamon desktop environment, we need to install three components to have proper icons. These are `mint-x-icons`, `mint-y-icons` and `mint-themes`, where the first two are dependencies for the third. These need to be manually compiled from source using `yay` because they are inaccessible from the AUR directly. These files are pulled from the servers that host Linux Mint's actual development tools and are built using a `PKGBUILD` file. We also need to make the proper directories for the themes to be stored. The repositories for `flat-remix` are directly cloned into the newly created directories for their respective themed elements. `GTK` themes which include window and panel themes are placed in the `themes` subdirectory and icons go to `icons`.


### dot_file_installer

This function is not even really necessary if you structure your dot file repository "properly", where it directly mirrors your home directory. I split mine into specific directories, denoting which applications pull from what. I feel like this way opens up more possibilities for configuration files outside of the one central location. The only problem is that when you need to run separate `cp` commands for each individual file and it's respective location. Also, these commands need to be run by the user in which you are intending on using as you will run into permission errors. That's why if you look [here](https://google.com), you can see commands being issued as "$user". Here we are also launching `dconf` with `dbus-launch` so we can run an application meant to run in a graphical environment from the shell. We are not interested in starting the `lightdm` service until we are all finished with all of the configuration, also allowing for this function to be run in any order needed. Basic `git` configuration is also included here.

### application_installer

Some applications that we would like to install can be found in the AUR natively which is the ideal case. There is no need to compile these programs from source. Here it becomes a trade off of time to desire. For instance, I really want to have vmware-workstation installed on my machine but the installer is nearly 500 MBs which is the compiled bundle alone. This tells you that vmware will take a long time to pull resources then take a fair amount of time compiling. Since I need this program for writing this tutorial and other testing environments, I am okay with the extra time. This function will take as long as you would like it to be and for me it takes about 15 minutes with a good connection and decent hardware. Your mileage may vary. Arch Linux has these odd .desktop files with "avahi" in them so I remove them because I have no need for them.


### programming_environments

This function is variable to change and will most likely be updated when I take more computer science courses. We also pull Python modules for all of the various tools I have/will create. There is this great resource in the form of C++ manuals that have been ported from [cppreference](https://en.cppreference.com/w/). I find them easier to access directly from the terminal rather than using the website directly. There is tab completion through `man` itself and has helped me through several coding projects in university. Installing `most` will also give automatic color support for `man`, which definitely helps on the readability. You need to configure your shell's configuration file by adding this one line:

```bash
export PAGER="most"
```
and then sourcing it.

# External Links

[Fixing ZSH Icons](https://unix.stackexchange.com/questions/429946/zsh-icons-broke-in-urxvt)

[Font Settings for Panel](https://forums.linuxmint.com/viewtopic.php?t=106758)
