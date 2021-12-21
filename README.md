# Thin Mint

My installation scripts for a minimal Arch Linux setup, aimed for developers.

# Foreword

These scripts are more of a basic outline of how my machine operates and how my development environment is structured.
I was trying to replicate as closely a I could all of my favorite aspects of Linux Mint and combine it with the efficiency of Arch. 

# Installation Process

## Base Install

This portion of the installation is concerned with installing a bare Arch Linux environment with persistent internet and file system. 
The process consists of these steps:

- Partitioning the drive to store the boot loader, root and swap partitions.
- Formatting the drives (different partitions we just created) so we can properly use them
- Mounting the newly created file system allow both partitions get the files they need
- Install all the necessary components for an Arch Linux install and the development tools
- Tell `fstab` where all of the drives are
- Setting the correct timezone
- Only using English locales
- Setting `hostname` and the ability to ping yourself
- Installing GRUB
- Internet persistence using `dhcpcd`
- Unmounting and rebooting

## Desktop Install

Here we are installing the next layer which is the graphical environment, install applications, create users and make edits to configuration files. 
This process consists of these steps:

- Installing the necessary packages and users
- Create the user we are going to use permanently (i.e) )`jared`
- Configuring the terminal 
    * `zsh`, `vim`, `urxvt`
- Installing the necessary layers for a graphical installation to work
    * Setting the correct greeter
- Install "proper" themes
- Install configuration files for various programs
    * `git`, `cinnamon`, `scripts`
- Add home directory structure
- Install user applications
    * `Discord`, `Slack`, etc

## Hardware Configuration

The Dell XPS 15 has some quirks that need to be addressed such as the power hungry GTX 1050 graphics card. 
In this instance, we can safely disable this component. 
This process includes:

- Setting up a service that tells the kernel to not load the graphics card at start up so we don't have to do it every time
- Power saving help from `tlp`

# Other Notes

Running this on the desktop test environment should include the following steps before proceeding:

```bash
rmmod tg3 pcspkr
modprobe broadcom
modprobe tg3
```

Thank you to [this](https://bbs.archlinux.org/viewtopic.php?id=110026) Arch forum thread!
