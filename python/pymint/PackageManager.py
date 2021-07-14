#!/usr/bin/env python3.9

import pathlib
import shutil
import re

from CommandParser import file_matcher, command_runner


class PackageManager:
    def __init__(self, path: str):
        if not(isinstance(path, str)):
            raise ValueError

        self.path = path

    def install(self, package: str):
        raise NotImplementedError

    def update_cache(self):
        raise NotImplementedError

    def list_installed(self):
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
