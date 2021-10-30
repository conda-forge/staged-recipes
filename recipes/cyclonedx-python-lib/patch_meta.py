import os
import re
from pathlib import Path

PATCHES = {
    r"""'setuptools>[^']+'""": """'setuptools>=50.3.2,<59'"""
}

SRC_DIR = Path(os.environ["SRC_DIR"])

DIST = SRC_DIR / "dist"
SETUP_PY = DIST / "setup.py"

(DIST / "pyproject.toml").unlink()

text = SETUP_PY.read_text(encoding="utf-8")

for pattern, replacement in PATCHES.items():
    text = re.sub(pattern, replacement, text)

SETUP_PY.write_text(text, encoding="utf-8")
