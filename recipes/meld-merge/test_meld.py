#!/usr/bin/env python3

import os
import sys
import subprocess
from pathlib import Path
from shlex import quote


BEFORE_PY = """\
import os
import sys
import json
import time
import pathlib
import urllib

def main():
    print("This file does nothing useful.")
    print(f"Python version: {sys.version.split()[0]}")
    print(f"Current working directory: {pathlib.Path.cwd()}")

if __name__ == "__main__":
    main()
"""

AFTER_PY = """\
import sys
import json
import random
import datetime
import math
import time
import collections
import pathlib
import httplib

def main():
    print("This file does nothing useful.")
    print(f"Python version: {sys.version.split()[0]}")
    print(f"Current working directory: {pathlib.Path.cwd()}")

if __name__ == "__main__":
    main()
"""

PNG_MAGIC = b'\x89PNG\r\n\x1a\n'

def run(args, **kwargs):
    cmdline = ' '.join(quote(arg) for arg in args)
    print(f"> {cmdline}", file=sys.stderr)
    subprocess.check_call(args, **kwargs)

def verify_png(path: Path):
    if not path.exists():
        raise RuntimeError(f"{path} doesn't exist")
    with path.open('rb') as f:
        prefix = f.read(len(PNG_MAGIC))
    if prefix != PNG_MAGIC:
        raise RuntimeError(f"{path} is not a PNG file")

def test_meld(workdir: Path):
    before_fn = workdir / 'before.py'
    before_fn.write_text(BEFORE_PY)
    after_fn = workdir / 'after.py'
    after_fn.write_text(AFTER_PY)
    screenshot_fn = workdir / 'screenshot.png'
    screenshot_fn.unlink(missing_ok=True)
    # To enable syntax highlighting, we could run this, but only after a first run, to create the setting.
    # run("gsettings set org.gnome.meld highlight-syntax true".split())
    env = os.environ.copy()
    env['MELD_SCREENSHOT_AND_EXIT'] = str(screenshot_fn)
    # Prepending "xvfb-run" makes this work on a headless Linux runner, but it need to be installed before that.
    # To install:
    # sudo yum install xorg-x11-server-Xvfb
    run(["xvfb-run", "meld", str(before_fn), str(after_fn)], env=env)
    verify_png(screenshot_fn)

def main():
    from argparse import ArgumentParser

    parser = ArgumentParser(description="test that meld works")
    parser.add_argument("--workdir", type=Path, default=Path('.'), help="Directory in which to create files")
    args = parser.parse_args()

    test_meld(args.workdir)

if __name__ == '__main__':
    main()

