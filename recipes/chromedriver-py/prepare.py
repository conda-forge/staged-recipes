"""Trim the vendored driver set down to this platform.

Run from the source work directory as:  python prepare.py <host_platform>
"""

import os
import sys

BINARY_FOR = {
    "linux-64": "chromedriver_linux64",
    "osx-64": "chromedriver_mac-x64",
    "osx-arm64": "chromedriver_mac-arm64",
    "win-64": "chromedriver_win64.exe",
}

PKG = "chromedriver_py"


def main(host_platform):
    try:
        keep = BINARY_FOR[host_platform]
    except KeyError:
        sys.exit("no upstream chromedriver build for %s" % host_platform)

    # The sdist bundles every platform's driver. Ship only this one.
    for name in sorted(os.listdir(PKG)):
        if name.startswith("chromedriver_") and name != keep:
            os.remove(os.path.join(PKG, name))
            print("removed %s/%s" % (PKG, name))

    binary = os.path.join(PKG, keep)
    if not os.path.isfile(binary):
        sys.exit("expected driver missing: %s" % binary)
    os.chmod(binary, 0o755)
    print("kept %s (%d bytes)" % (binary, os.path.getsize(binary)))


if __name__ == "__main__":
    main(sys.argv[1])
