import os
import sys
from pathlib import Path

VERSION = Path(os.environ["PKG_VERSION"])
SRC = Path(os.environ["SRC_DIR"])
PREFIX = Path(os.environ["PREFIX"])

ALL_SRC = sorted(SRC.glob("*"))

OUT = PREFIX / "share/vale/styles"
DICPATH =  PREFIX / "share/hunspell_dictionaries/"

PKG = os.environ["PKG_NAME"].replace("vale-spelling-", "")
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
custom: true
action:
  name: suggest
dicpath: {dicpath}
dictionaries:
  - {locale}
"""

TEMPLATES = {
    META_PATH: META_JSON_TEMPLATE,
    RULE_PATH: RULE_YML_TEMPLATE,
}


def write_config():
    dic = next(PATH.glob("*.dic")).stem
    ctx = {"locale": dic, "version": VERSION, "dicpath": DICPATH}
    RULE_PATH.parent.mkdir(exist_ok=True, parents=True)
    for path, template in TEMPLATES.items():
        print("\n-----------", path, "-----------")
        text = template.format(**ctx)
        print(text)
        path.write_text(text, encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(write_config())
