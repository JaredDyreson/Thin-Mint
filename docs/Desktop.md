# Desktop

## User space Functions

### make_root

Give the supplied user root access to the machine

### password_management

Ask for password input until both passwords are the same. Change the current password for a given user and store it in a temporary file in the home directory

### check_user

Check for the presence of a given user, returning true if they have been found in /etc/passwd

### create_user

Instantiate a user given a name with the correct folder structure and projects

### initial_configuration

Make sure the builduser is present and removes any potential roadblocks the script may encounter during installation. It also installs git, sudo, dialog, python and zsh which are all tools used during the install process.

### change_password

Change the password for root and return that value


## Installation Functions


# External Links

[Fixing ZSH Icons]()
[Font Settings for Panel]()
