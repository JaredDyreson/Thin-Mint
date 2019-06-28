# Thin Mint
My rice scripts for my Linux Mint Cinnamon 18.2 setup. If you see references to `mintyrice`, that was the old repository name.

# Foreword

These scripts are more of a basic outline of how my machine actually operates and what my development environment actually looks like. This was the last part of the puzzle in my back up solution methodology which you can find [right here](https://github.com/JaredDyreson/mintyrice/docs/backup-solution.md). Also, the title is a little misleading as these scripts were built on top of a bare Arch Linux installation. I was trying to replicate as closely a I could all of my favorite aspects of Linux Mint and combine it with the efficiency of Arch. The migration has yet to happen because I don't want to squander the perfectly good installation I have already. That was not the point of this repository. I also treated this as an unexpected learning experience in which I got my hands dirty in the Linux command line more than I ever have. Installing Arch Linux fits into this Linux paradigm, in it being a right of passage. Now, after wanting to pull my hair out on several occasions, I now have created an easy to understand, **well** documented installation guide. Please, if you have any critiques, please make a pull request and I will make sure it is addressed. Also, as cliche as it is, the [Arch Wiki](https://wiki.archlinux.org/) is your friend.

# Installation Process

## Base Install

This portion of the installation is concerned with installing a bare Arch Linux environment with persistent internet and filesystem. The process consists of these steps:

- Partitioning the drive to store the boot loader and root partition (no swap included)
- Formatting the drives (different partitions we just created) so we can properly use them
- Mounting the newly created filesystem to mount in a way where both partitions get the files they need
- Install all the necessary components for an Arch Linux install and the develpment tools because I will need them
- Tell fstab where all of the drives are
- Setting the correct timezone
- Only using English locales
- Setting hostname and the ability to ping yourself ;P
- Installing GRUB
- Internet persistence using dhcpcd
- Unmounting and rebooting

### Running this portion

```bash
curl -sL https://git.io/fjVo3 | bash
```

## Desktop Install

Here we are installing the next layer which is the graphical environment. Here we are allowed to install applications, create users and make edits to configuration files. This process consists of these steps:

- Installing the necessary packages and users for a smooth install
- Create the actual user we are going to use permanently (i.e) jared)
- Configuring the terminal (zsh,vim,ranger,urxvt)
- Installing the necessary layers for a graphical installation to work (setting the correct greeter so it looks nice)
- Install "proper" themes
- Install configuration files for various programs (git,cinnamon,ranger,scripts)
- Add proper home folder things (Projects added here as well)
- Install user applications like Spotify, VLC, Discord, etc.
- Other useful tools used infrequently

### Running this portion

```bash
curl -sL https://git.io/fjwVT | bash
```

## Hardware Configuration

The Dell XPS 15 has some quirks that need to be addressed such as the power hungry GTX 1050 graphics card. Since I program and not a graphic designer, we can safely disable this component. This process includes:

- Setting up a service that tells the kernel to not load the graphics card at start up so we don't have to do it every time
- Power saving help from tlp

### Running this portion

```bash
https://git.io/fjoik
```

## Main

This script will automatically call each individual script through cURL. These scripts were meant to be modular in order to help increase readability and usage.

### Running this portion

```bash
curl -sL https://git.io/fjoiG
```

# External Links

A much more in depth look can be found on my blog [here](https://JaredDyreson.github.io).
