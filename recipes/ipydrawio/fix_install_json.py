"""fix some bad metadata paths"""
import os
import sys
from pathlib import Path

INSTALL_JSON = Path(sys.prefix) / "share/jupyter/labextensions/install.json"

if INSTALL_JSON.exists():
    INSTALL_JSON.unlink()
else:
    print("Didn't find, couldn't delete", INSTALL_JSON)
