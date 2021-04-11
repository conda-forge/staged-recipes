"""fix some bad metadata paths"""
import os
import sys
from pathlib import Path

INSTALL_JSON = Path(sys.prefix) / "share/jupyter/labextensions/install.json"

INSTALL_JSON.unlink()
