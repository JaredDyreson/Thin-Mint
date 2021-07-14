#!/usr/bin/env python3.10

"""
Goal: apply several regexes to the output of
a shell command and grab them as a tuple
"""

import os
import re
import shutil
import subprocess
import textwrap
import pathlib
import functools


def helper_function(content: str, regex: re.Pattern, find_all: bool) -> tuple[str]:
    """
    Match the contents of a given string to the given regex
    Will fail if the regex cannot find anything
    """

    if not(isinstance(content, str) and
           isinstance(regex, re.Pattern)):
        raise ValueError(f'{content=}, {regex=}')

    container = list(regex.groupindex.keys())
    content = textwrap.dedent(content).strip()

    regex_function = functools.partial(
        regex.findall if find_all else regex.search,
        string=content
    )
    if((_match := regex_function()) is None):
        raise ValueError(
            f'{_match=} is not a valid match (re of {regex=}) for string ({content=})')

    match container:
        case[_]:
            return _match.groups()
        case _:
            if not(_match):
                raise ValueError(f'groups not utilized')
            else:
                return _match


def file_matcher(content: str, regexes: list[re.Pattern], find_all: bool = True) -> list[str]:
    """
    Match the contents of an output stream
    to a list of regexes
    """

    if not(isinstance(content, str) and
           isinstance(regexes, list) and
           all([isinstance(_, re.Pattern) for _ in regexes]) and
           (argc := len(regexes))):
        raise ValueError

    if(argc < 2):
        return helper_function(content, *regexes, find_all)

    return [
        helper_function(content, regex, find_all) for regex in regexes
    ]


def command_runner(command: str):
    if not(isinstance(command, str)):
        raise ValueError

    if not(bash := shutil.which("bash")):
        raise OSError(f'cannot find `bash`, is this Linux?')

    return '\n'.join(subprocess.check_output(
        command,
        shell=True,
        executable=bash,
        encoding="utf-8",
        universal_newlines="\n").splitlines())
