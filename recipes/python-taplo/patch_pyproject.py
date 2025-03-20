from pathlib import Path
import os
import sys

UTF8 = {"encoding": "utf-8"}
PPT = Path("pyproject.toml")
PKG_VERSION = os.environ["PKG_VERSION"]
NEW_PROJECT = f"""[project]
version = "{PKG_VERSION}"
"""

def main() -> int:
    old_text = PPT.read_text(**UTF8)
    new_text = old_text.replace("[project]", NEW_PROJECT)
    print("-" * 80)
    print(new_text)
    print(f"new {PPT}")
    print("-" * 80)
    PPT.write_text(new_text, **UTF8)
    return 0

if __name__ == "__main__":
    sys.exit(main())
