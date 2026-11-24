#!/usr/bin/env python3
"""Print the `context:` block of recipe.yaml for a given pdfium build number.

pdfium has no releases; each version is a `chromium/<build>` branch, and the
vendored build dependencies must match the revisions pinned in its DEPS file.
Usage: python update_context.py 8149   (then paste the output into recipe.yaml
and update the sha256 of generate_shim_headers.py as printed).
"""
import base64
import hashlib
import re
import subprocess
import sys
import urllib.request

DEPS_KEYS = ["build", "abseil", "fast_float", "simdutf", "dragonbox", "highway"]


def ls_remote(url, pattern):
    out = subprocess.run(["git", "ls-remote", url, pattern], check=True,
                         capture_output=True, text=True).stdout.split()
    if not out:
        sys.exit(f"{pattern!r} not found in {url}")
    return out


def main(build):
    pdfium_rev = ls_remote("https://pdfium.googlesource.com/pdfium",
                           f"refs/heads/chromium/{build}")[0]
    tag = ls_remote("https://chromium.googlesource.com/chromium/src.git",
                    f"refs/tags/*.*.{build}.0")[1]
    version = tag.rsplit("/", 1)[-1]
    deps_url = f"https://pdfium.googlesource.com/pdfium/+/{pdfium_rev}/DEPS?format=TEXT"
    deps = base64.b64decode(urllib.request.urlopen(deps_url).read()).decode()
    shim_url = ("https://raw.githubusercontent.com/chromium/chromium/"
                f"{version}/tools/generate_shim_headers/generate_shim_headers.py")
    shim_sha = hashlib.sha256(urllib.request.urlopen(shim_url).read()).hexdigest()

    print("context:")
    print("  name: pdfium")
    print(f'  version: "{version}"')
    print(f'  build: "{build}"')
    print(f"  pdfium_rev: {pdfium_rev}")
    for key in DEPS_KEYS:
        m = re.search(rf"'{key}_revision': '(\w+)'", deps)
        if not m:
            sys.exit(f"{key}_revision not found in DEPS")
        print(f"  {key}_rev: {m.group(1)}")
    m = re.search(r"'gn_version': 'git_revision:(\w+)'", deps)
    if not m:
        sys.exit("gn_version not found in DEPS")
    gn_rev = m.group(1)
    print(f"\n# gn revision required by DEPS: {gn_rev} -- make sure the `gn` pin")
    print("# in requirements/build is at least as new (gn-feedstock versions are")
    print("# 0.0.<commit date as YYYYMMDDHHMMSS>).")
    print(f"\n# sha256 of generate_shim_headers.py: {shim_sha}")


if __name__ == "__main__":
    if len(sys.argv) != 2 or not sys.argv[1].isdigit():
        sys.exit(__doc__)
    main(sys.argv[1])
