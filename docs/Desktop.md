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

# External Links

[Fixing ZSH Icons]()
[Font Settings for Panel]()
