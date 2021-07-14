#!/usr/bin/env python3.10

from CommandParser import file_matcher, command_runner
from FileProcessor import ingest_file, find_replace, FindReplacePacket
import pathlib
import shutil
import re
import subprocess
import dataclasses


@dataclasses.dataclass
class FileSystemMap:
    efi: pathlib.Path,
    swap: pathlib.Path,
    root: pathlib.Path,
    home: pathlib.Path


def obtain_target_device() -> pathlib.Path:
    """
    Find the target device we need to install to
    """

    if not(lsblk := shutil.which("lsblk")):
        raise ValueError

    path = file_matcher(
        command_runner(f'{lsblk} -dplnx size -o name,size'),
        [re.compile("(?P<path>\/([\w]+(\/)?)+)")]
    )
    match path:
        case[devpath, _, _]:
            return pathlib.Path(devpath)
        case _:
            raise ValueError


def memory_currently_installed() -> int:
    """
    Get the current amount of physical memory
    in kilobytes
    """

    content = ingest_file("/proc/meminfo")
    total = file_matcher(
        content, [re.compile("MemTotal:\s*(?P<total>[\d]+)")])
    return int(*total)


def partition(swap_size: int, root_size: int, fdisk_script: pathlib.Path):
    """
    Partition the drive with a given swap, root and fdisk script
    """

    if not(isinstance(swap_size, int) and
           isinstance(root_size, int) and
           isinstance(fdisk_script, pathlib.Path) and
           fdisk_script.is_file()):
        raise ValueError

    with open(fdisk_script, "r") as fp:
        content = ''.join(fp.readlines())

    replacements: list[FindReplacePacket] = [
        FindReplacePacket(re.compile("\[SWAP\_SIZE\]"), swap_size),
        FindReplacePacket(re.compile("\[ROOT\_SIZE\]"), root_size)
    ]

    script = find_replace(
        content,
        replacements
    )

    fdisk_process = subprocess.run(
        ["rev"], input=script, stdout=subprocess.PIPE, encoding='ascii')

    # print(fdisk_process.stdout)


def wifi_menu_configuration():
    if not(ip := shutil.which("ip")):
        raise ValueError

    out = command_runner(f'{ip} link')
    print(out)

    interface = file_matcher(
        command_runner(f'ip link'),
        [re.compile("(?P<connection>wlp.*)\:")])[0]

    print(f'systemctl enable netctl-auto@{interface}.service')
    print("wifi-menu -o")


def unmount_all_partitions():
    paths: list[str] = [
        "/mnt/boot",
        "/mnt/home",
        "/mnt"
    ]
    for path in paths:
        command_runner(f'umount {path}')


def sub_partitions(base_dir: pathlib.Path) -> FileSystemMap:
    if not(isinstance(base_dir, pathlib.Path)):
        raise ValueError

    return FileSystemMap(
        f'{base_dir}1',
        f'{base_dir}2',
        f'{base_dir}3',
        f'{base_dir}4'
    )


def create_filesystem(manifest: FileSystemMap):

    assert((mkfsvfat := shutil.which("mkfs.vfat")) and
           (mkswap := shutil.which("mkswap")) and
           (swapon := shutil.which("swapon")) and
           (mkfsext := shutil.which("mkfs.ext4")))
    EFI, SWAP, ROOT, HOME = dataclasses.astuple(manifest)

    command_runner(f'{mkfsvfat} -F32 {EFI}')
    command_runner(f'{mkswap} {SWAP}')
    command_runner(f'{swapon} {SWAP}')
    command_runner(f'{mkfsext} {ROOT}')
    command_runner(f'{mkfsext} {HOME}')


def run():
    assert(dd := shutil.which("dd"))
    primary_drive = obtain_target_device()
    command_runner("timedatectl set-ntp true")
    command_runner(f'{dd} if=/dev/zero of={primary_drive} bs=512 count=1')

    memory_installed = int(memory_currently_installed() / 1048576)
    size_of_swap = memory_installed * 2
    root_size = 50
    partition(size_of_swap, root_size, pathlib.Path("/tmp/fdisk"))
