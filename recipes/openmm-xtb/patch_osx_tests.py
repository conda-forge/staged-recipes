import os
import sys
from pathlib import Path
from conda_build.os_utils import macho


def name_callback(path, dylib):
    prefix = os.environ["SRC_DIR"]
    if prefix.endswith("/"):
        prefix = prefix[:-1]

    if dylib["name"].startswith(prefix):
        return f"@rpath/{Path(dylib['name']).name}"


def main(path):
    dylibs = macho.otool(path)
    macho.install_name_change(path, None, name_callback, dylibs, verbose=True)


if __name__ == "__main__":
    main(sys.argv[1])