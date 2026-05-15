import glob
import json
import os
import sys


def fail(message):
    raise SystemExit(message)


prefix = os.environ["PREFIX"]
metadata_paths = glob.glob(os.path.join(prefix, "conda-meta", "filament-*.json"))

if len(metadata_paths) != 1:
    fail(f"expected exactly one filament package metadata file, found {metadata_paths!r}")

with open(metadata_paths[0], encoding="utf-8") as metadata_file:
    package_files = json.load(metadata_file)["files"]

static_archives = sorted(path for path in package_files if path.endswith(".a"))
if static_archives:
    fail("filament package ships static archives: " + ", ".join(static_archives))

shared_libraries = sorted(
    path
    for path in package_files
    if path.startswith("lib/libfilament")
    and (".so" in os.path.basename(path) or path.endswith(".dylib"))
)
if not shared_libraries:
    fail("filament package does not ship a shared libfilament library")

for forbidden_path in (
    "bin/basisu",
    "lib/libabseil.a",
    "lib/libbasis_transcoder.a",
    "lib/libcivetweb.a",
    "lib/libdracodec.a",
    "lib/libmeshoptimizer.a",
    "lib/libmikktspace.a",
    "lib/libperfetto.a",
    "lib/libsmol-v.a",
    "lib/libstb.a",
):
    if forbidden_path in package_files:
        fail(f"filament package ships vendored payload: {forbidden_path}")

for forbidden_prefix in ("include/mikktspace/", "include/tsl/"):
    matches = sorted(path for path in package_files if path.startswith(forbidden_prefix))
    if matches:
        fail("filament package ships vendored headers: " + ", ".join(matches[:10]))
