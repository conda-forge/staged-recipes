import os
import sys
from pathlib import Path

VERSION = Path(os.environ["PKG_VERSION"])
SRC = Path(os.environ["SRC_DIR"])
ALL_SRC = sorted(SRC.glob("*"))
OUT = Path(os.environ["PREFIX"]) / "share/vale/styles"

PKG = os.environ["PKG_NAME"].replace("vale-package-", "")
L10N = PKG.split("-")[-1].upper()
PATH = next(p for p in ALL_SRC if p.name.startswith(f"en_{L10N}") if p.is_dir())

META_PATH = OUT / PKG / "meta.json"
RULE_PATH = OUT / PKG / "Spelling.yml"

META_JSON_TEMPLATE = """{{
  "sources": [
    "https://github.com/marcoagpinto/aoo-mozilla-en-dict"
  ],
  "vale_version": ">=1.0.0",
  "version": "{version}"
}}"""

RULE_YML_TEMPLATE = """
---
extends: spelling
level: warning
message: "Did you really mean '%s'?"
dicpath: ../../hunspell_dictionaries
dictionaries:
  - {locale}
"""


def write_config():
    dic = next(PATH.glob("*.dic")).stem
    RULE_PATH.parent.mkdir(exist_ok=True, parents=True)
    RULE_PATH.write_text(RULE_YML_TEMPLATE.format(locale=dic), encoding="utf-8")
    META_PATH.write_text(META_JSON_TEMPLATE.format(version=VERSION), encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(write_config())
