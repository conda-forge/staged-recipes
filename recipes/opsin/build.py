"""Install the OPSIN jar, the command wrappers and the licence texts.

Runs on every platform (rattler-build calls it with the build environment's python).
"""
import os
import shutil
import zipfile
from pathlib import Path

prefix = Path(os.environ["PREFIX"])
recipe_dir = Path(os.environ["RECIPE_DIR"])
src = Path(os.environ.get("SRC_DIR", os.getcwd()))
jar = src / "opsin.jar"

# The jar, at a path that does not change between versions.
share = prefix / "share" / "opsin"
share.mkdir(parents=True, exist_ok=True)
shutil.copy2(jar, share / "opsin.jar")

# Command wrappers: bash for Linux and macOS, batch for Windows.
bin_dir = prefix / "bin"
bin_dir.mkdir(parents=True, exist_ok=True)
shutil.copy2(recipe_dir / "opsin", bin_dir / "opsin")
os.chmod(bin_dir / "opsin", 0o755)
shutil.copy2(recipe_dir / "opsin.bat", bin_dir / "opsin.bat")

# Licence texts that ship inside the jar.
# Each file is byte-identical to the file of the same name in the library's own jar.
licenses = src / "licenses"


def extract(member: str, folder: str) -> None:
    out = licenses / folder
    out.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(jar) as zf:
        (out / Path(member).name).write_bytes(zf.read(member))


extract("META-INF/LICENSE", "woodstox-core")      # woodstox-core 7.1.1
extract("META-INF/LICENSE.txt", "commons-io")     # commons-io 2.21.0, full Apache-2.0 text
extract("META-INF/NOTICE.txt", "commons-io")      # commons-io 2.21.0
extract("META-INF/NOTICE", "log4j-core")          # log4j-core 2.25.3
extract("META-INF/AL2.0", "jna")                  # JNA 5.10.0
extract("META-INF/LGPL2.1", "jna")                # JNA 5.10.0

# RELAX NG datatype library: licence file from the release archive.
(licenses / "relaxngDatatype").mkdir(parents=True, exist_ok=True)
shutil.copy2(src / "upstream" / "relaxngDatatype" / "copying.txt",
             licenses / "relaxngDatatype" / "copying.txt")

# ISO RELAX: the MIT licence is in the source file headers; keep the header of one file.
with zipfile.ZipFile(src / "upstream" / "isorelax-sources.jar") as zf:
    text = zf.read("org/iso_relax/dispatcher/SchemaProvider.java").decode("utf-8", "replace")
header_lines = []
for line in text.splitlines(keepends=True):
    header_lines.append(line)
    if line.rstrip().endswith("*/"):
        break
header = "".join(header_lines)
if "Permission is hereby granted" not in header:
    raise SystemExit("ISO RELAX: the MIT licence header was not found in SchemaProvider.java")
(licenses / "isorelax").mkdir(parents=True, exist_ok=True)
(licenses / "isorelax" / "LICENSE-from-source-header.txt").write_text(header, encoding="utf-8")

for path in sorted(p for p in licenses.rglob("*") if p.is_file()):
    print(path.relative_to(src).as_posix())
