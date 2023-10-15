"""Find/check the license files in $SRC_DIR/third-party

Usage:

    print out a YAML-ish list of licenses

    >>> python find_licenses.py

    ensure the $RECIPE_DIR/meta.yaml is up-to-date

    >>> python find_licenses.py --check

"""
from typing import List
from pathlib import Path
import os
import sys
import re
import difflib

DELIM = "    # LICENSES"

SRC_DIR = Path(os.environ["SRC_DIR"])
RECIPE_DIR = Path(os.environ["RECIPE_DIR"])
META_YAML = RECIPE_DIR / "meta.yaml"
THIRD_PARTY = SRC_DIR / "thirdparty"
PATTERNS = [
    r"COPY(RIGHT|ING)",
    r"LICEN[SC]E",
    r"license.txt",
]
FIRST_PARTY = [
    "LICENSE.txt",
    "COPYRIGHT.txt",
]


def main(check: bool) -> int:
    paths: List[str] = [*FIRST_PARTY]
    for path in THIRD_PARTY.rglob("*"):
        str_path = path.relative_to(SRC_DIR).as_posix()
        if any(re.search(p, str_path) for p in PATTERNS):
            paths += [str_path]
    inner_text = "\n".join([f"    - {p}" for p in sorted(paths)])
    lines = [
        f"  license_file:",
        DELIM,
        inner_text,
        DELIM,
    ]
    text = "\n".join(lines)
    print(text)
    if check:
        print(f"# ... checking {META_YAML} ...")
        yaml_text = META_YAML.read_text(encoding="utf-8")
        yaml_chunk = yaml_text.split(DELIM)[1]
        diff = list(
            difflib.unified_diff(
                yaml_chunk.strip().splitlines(),
                inner_text.strip().splitlines(),
                str(META_YAML),
                str(SRC_DIR),
            )
        )
        if diff:
            print("\n".join(diff))
            print("# FAIL\n# please update licenses")
            return len(diff)
        print("# OK!")
    return 0


if __name__ == "__main__":
    sys.exit(main("--check" in sys.argv))
