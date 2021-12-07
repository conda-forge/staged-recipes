from pathlib import Path
import os

SRC_DIR = Path(os.environ["SRC_DIR"])
SETUP_PY = SRC_DIR / "setup.py"
UTF8 = dict(encoding="utf-8")
PKG_VERSION = os.environ["PKG_VERSION"]

SETUP_PY.write_text(
    SETUP_PY.read_text(**UTF8).replace(
        '''version='0.0.0',''',
        f'''version='{PKG_VERSION}','''
    ),
    **UTF8
)

print("added", PKG_VERSION, "to", SETUP_PY, ":")
print(SETUP_PY.read_text(**UTF8))
