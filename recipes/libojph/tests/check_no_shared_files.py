import json
import pathlib
import sys

meta = pathlib.Path(sys.prefix) / "conda-meta"


def files(name):
    for record in meta.glob(f"{name}-*.json"):
        data = json.loads(record.read_text())
        if data["name"] == name:
            return set(data["files"])
    raise SystemExit(f"{name} is not installed")


libojph = files("libojph")
openjph = files("openjph")
print(f"libojph: {len(libojph)} files, openjph: {len(openjph)} files")
shared = sorted(libojph & openjph)
if shared:
    raise SystemExit("files in both packages:\n" + "\n".join(shared))
