"""Strip the C extension declaration from pyproject.toml.

Used by build.sh and bld.bat so the resulting wheel is pure Python (noarch).
The geomserde_speedup extension only accelerates the PySpark serialization
codepath, which is unused in this lightweight build (no pyspark dep). The
Python fallback in sedona/spark/utils/geometry_serde.py handles the case
where the compiled module is absent.
"""

import pathlib
import re
import sys


def main() -> int:
    path = pathlib.Path("pyproject.toml")
    text = path.read_text()
    pattern = re.compile(
        r"\n*(?:#[^\n]*\n)*\[\[tool\.setuptools\.ext-modules\]\][\s\S]*?(?=\n\[|\Z)"
    )
    new_text, count = pattern.subn("\n", text)
    if count != 1:
        sys.stderr.write(
            f"strip_ext_modules: expected 1 match, got {count}\n"
        )
        return 1
    path.write_text(new_text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
