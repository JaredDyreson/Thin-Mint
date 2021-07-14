import dataclasses
import pathlib
import re


@dataclasses.dataclass
class FindReplacePacket:
    find: re.Pattern
    replace: str


def ingest_file(path: str) -> str:
    if not(isinstance(path, str)):
        raise ValueError(
            f'did not receive type `str`, obtained {type(path).__name__}')
    with open(pathlib.Path(path), "r") as fp:
        return ''.join(fp.readlines())


def find_replace(content: str, replacements: list[FindReplacePacket]) -> str:
    for replacement in replacements:
        find, replace = dataclasses.astuple(replacement)
        content = find.sub(str(replace), content)
    return content
