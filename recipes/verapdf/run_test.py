import platform
import shutil
from pathlib import Path
import os
import sys
import subprocess


WIN = platform.system() == "Windows"
SCRIPT_EXT = ".bat" if WIN else ""
PKG_VERSION = os.environ["PKG_VERSION"]
MATTERHORN = "Matterhorn-Protocol-1-1.pdf"
PYTEST_ARGS = [sys.executable, "-m", "pytest", "-vv", "--color=yes", __file__]

import pytest

def _find_cmd(cmd):
    return shutil.which(f"{cmd}{SCRIPT_EXT}")

def _verapdf(*args: str):
    proc = subprocess.Popen(
        [_find_cmd("verapdf"), *args],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        encoding="utf-8",
    )
    stdout, stderr = proc.communicate()
    return proc.returncode, stdout, stderr


@pytest.mark.parametrize("cmd", ["verapdf", "verapdf-gui"])
def test_cmd_exists(cmd: str):
    assert Path(_find_cmd(cmd)).exists()


def test_cmd_help():
    rc, stdout, stderr = _verapdf("--help")
    assert PKG_VERSION in stdout
    assert not stderr
    assert rc == 0


def test_cmd_version():
    rc, stdout, stderr = _verapdf("--version")
    assert PKG_VERSION in stdout
    assert not stderr
    assert rc == 0


def test_cmd_validate():
    rc, stdout, stderr = _verapdf("--format", "text", "--flavour", "ua1", MATTERHORN)
    assert "PASS" in stdout
    assert not stderr
    assert rc == 0


if __name__ == "__main__":
    sys.exit(subprocess.call(PYTEST_ARGS))
