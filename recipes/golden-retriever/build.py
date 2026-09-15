import os
import subprocess
import sys
from pathlib import Path


pyproject = Path("pyproject.toml")
contents = pyproject.read_text(encoding="utf-8")
sentinel = 'version = "0.0.0"'
version = os.environ["PKG_VERSION"]
replacement = f'version = "{version}"'

# Tag archives retain the 0.0.0 sentinel because upstream substitutes the
# release version only in its CI build checkout.
if contents.count(sentinel) != 1:
    raise RuntimeError(
        f"expected exactly one {sentinel!r} declaration in {pyproject}"
    )

pyproject.write_text(
    contents.replace(sentinel, replacement),
    encoding="utf-8",
    newline="",
)

subprocess.run(
    [
        sys.executable,
        "-m",
        "pip",
        "install",
        ".",
        "-vv",
        "--no-deps",
        "--no-build-isolation",
    ],
    check=True,
)
