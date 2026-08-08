#!/usr/bin/env python3

import os
import shutil
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

def run(args, extra_env=None):
    if extra_env is None:
        extra_env = {}
    env = os.environ.copy()
    for k, v in extra_env.items():
        env[k] = v
    cmdline = ' '.join(quote(arg) for arg in [f'{k}={v}' for k, v in extra_env.items()] + args)
    print(f"> {cmdline}", file=sys.stderr)
    subprocess.check_call(args, env=env)

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
    extra_env = {'MELD_SCREENSHOT_AND_EXIT': str(screenshot_fn)}
    args = ["meld", str(before_fn), str(after_fn)]
    if sys.platform == 'linux':
        # On Linux we need xvfb for a headless run
        args.insert(0, 'xvfb-run')
        if not shutil.which('xvfb-run'):
            if shutil.which('yum'):
                run(['sudo', '-n', 'yum', 'install', '-y', 'xorg-x11-server-Xvfb'])
            elif shutil.which('apt-get'):
                run(['sudo', '-n', 'apt-get', 'install', '-y', 'xvfb'])
            else:
                raise RuntimeError("Couldn't find xvfb-run, yum, and apt-get, so I don't know how to install xvfb")

    run(args, extra_env=extra_env)

    verify_png(screenshot_fn)

def main():
    from argparse import ArgumentParser

    parser = ArgumentParser(description="test that meld works")
    parser.add_argument("--workdir", type=Path, default=Path('.'), help="Directory in which to create files")
    args = parser.parse_args()

    test_meld(args.workdir)

if __name__ == '__main__':
    main()

