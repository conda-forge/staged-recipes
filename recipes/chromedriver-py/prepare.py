"""Trim the vendored driver set down to this platform and surface the
ChromeDriver license files that upstream's sdist does not carry.

Run from the source work directory as:  python prepare.py <target_platform>
"""

import os
import shutil
import sys

BINARY_FOR = {
    "linux-64": "chromedriver_linux64",
    "osx-64": "chromedriver_mac-x64",
    "osx-arm64": "chromedriver_mac-arm64",
    "win-64": "chromedriver_win64.exe",
}

PKG = "chromedriver_py"
NOTICES = "chromedriver-dist"


def main(target_platform):
    try:
        keep = BINARY_FOR[target_platform]
    except KeyError:
        sys.exit("no upstream chromedriver build for %s" % target_platform)

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

    # LICENSE.chromedriver and THIRD_PARTY_NOTICES.chromedriver only exist in
    # Google's archive. Copy them to the work root so license_file can name them.
    found = []
    for root, _, files in os.walk(NOTICES):
        for name in files:
            if name.endswith(".chromedriver"):
                shutil.copyfile(os.path.join(root, name), name)
                found.append(name)

    missing = {"LICENSE.chromedriver", "THIRD_PARTY_NOTICES.chromedriver"} - set(found)
    if missing:
        sys.exit("license files not found under %s/: %s" % (NOTICES, sorted(missing)))
    print("staged %s" % sorted(found))


if __name__ == "__main__":
    main(sys.argv[1])
