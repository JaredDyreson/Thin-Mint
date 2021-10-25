#!/usr/bin/env python3.9

import dataclasses
import pathlib
import shutil
import re

from CommandParser import file_matcher, command_runner


@dataclasses.dataclass
class PackageInstance:
    architecture: str
    is_installable: bool
    name: str
    version: str


class PackageManager:
    def __init__(self, path: str, managed_object=None, secondary_manager=None):
        if not(isinstance(path, str)):
            raise ValueError
        """
        path: absolute path to the binary used
        managed_object: objects that should be controlled using a PackageManager
                        For example: Tuffix/Keyword.py
        secondary_manager: if the target system has another package manager to handle building packages from source
                           please use this. For example: Arch Linux
        """

        self.path = path
        self.managed_object = managed_object
        self.secondary_manager = secondary_manager

    def install(self, package: str):
        """
        Install a package from the sancitioned
        repositories on your system
        """
        if not(isinstance(package, str)):
            raise ValueError(
                f'expected `str`, obtained {type(package).__name__}')

    def install_bulk(self, packages: list[str]):
        if not(isinstance(packages, list) and
               all([isinstance(_, str) for _ in packages])):
            raise ValueError(
                f'expected list[str], obtained {type(packages).__name__}')

        for pkg in packages:
            self.install(pkg)

    def install_from_file(self, path: pathlib.Path):
        """
        Install package from a local file
        """
        if not((istype := isinstance(path, pathlib.Path)) and
               (is_present := path.is_file())):
            raise ValueError(f'istype: {istype} and is_present: {is_present}')

    def update_cache(self) -> None:
        """
        Rebuild the cache of packages you can install
        """

        raise NotImplementedError

    def build_installed_cache(self) -> None:
        """
        Get a dictionary of PackageInstance objects
        """
        raise NotImplementedError

    def list_installed(self, foreign: bool = False):
        """
        List the packages installed on the system
            foreign: packages built using another package manager such as `yay` or `yaourt`
        """
        raise NotImplementedError

    def install_source(self, string: str):
        """
        Install a repository on the target machine
        """

        raise NotImplementedError

    def install_gpg_key(self, path: str):
        """
        Install gpg key on machine
        Example: apt-key add [PATH]
        Targets Debian machines mostly
        """
        raise NotImplementedError


class Pacman(PackageManager):
    def __init__(self, path: str):
        super().__init__(path)

        self.installed = self.list_installed()

    def list_installed(self):
        """
        Search the output of pacman to see which
        packages have been installed
        """

        contents = file_matcher(
            command_runner(f'{self.path} -Qe'),
            [re.compile("(?P<pkg>[a-zA-Z\-\_0-9]+)\s*(?P<version>.*)")],
            find_all=True
        )
        container = {}
        for element in contents:
            pkg, version = element
            container[pkg] = version
        return container

    def is_installed(self, package: str, use_old_cache=True):
        """
        Check cache to see if the package has been successfully
        installed.
        use_old_cache: use cache when class is first initialized
                       if set to False, it will rebuild the cache
        """

        if not(isinstance(package, str)):
            raise ValueError
        try:
            if not(use_old_cache):
                self.installed = self.list_installed()
            self.installed[package]
        except KeyError:
            return False

        return True

    def download(self, packages: list[str], output: pathlib.Path, group=None):
        if not(isinstance(packages, list) and
               all([isinstance(_, str) for _ in packages])):
            raise ValueError

        if not(output.is_dir()):
            output.mkdir()

        command_runner(
            f'sudo {self.path} -Syw --cachedir {output} {" ".join(packages)}')


if not((pacman := shutil.which("pacman"))):
    raise EnvironmentError

__PackageManager = Pacman(pacman)
__PackageManager.download(["gimp"], pathlib.Path("/tmp/example"))
