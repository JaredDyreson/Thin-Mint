# Base Installation

# Drive Mapping

The base disk is the first disk detected by using `lsblk`, for the XPS, this is going to be `nvmen1`

1. EFI (512 MB)
2. SWAP (Twice the amount of RAM installed)
3. ROOT (100 GB)
4. HOME (Rest of disk)

We can pass in the following environment variables to alter the size of each partition:

- `ROOT_PARTITION_SIZE`
- `SWAP_SIZE`

Please see [here](https://github.com/JaredDyreson/Thin-Mint/tree/devbranch/configurations#readme) for more information about all the possible environment variables to set.

# Clearing of partitions

We are using `dd` to delete the entire partition table and new partitions will be made in their place.

# Booting into UEFI Shell

```nsh
bcfg boot add 1 fs0:/EFI/grub/grubx64.efi "Added via script"
exit
```
