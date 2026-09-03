import json
import os
import re
from pathlib import Path


prefix = Path(os.environ["PREFIX"])
record_path = next((prefix / "conda-meta").glob("rtabmap-*.json"))
record = json.loads(record_path.read_text(encoding="utf-8"))
owned_files = [Path(path) for path in record["files"]]

forbidden_fragments = (
    "convertutf",
    "lz4.c",
    "lz4.h",
    "lz4hc.c",
    "lz4hc.h",
    "madgwickfilter",
    "orbextractor",
    "simpleini",
    "sqlite3.c",
    "toro3d",
    "vertigo",
)
leaked = [
    str(path)
    for path in owned_files
    if any(fragment in str(path).lower() for fragment in forbidden_fragments)
]
assert not leaked, f"bundled or disabled source leaked into package: {leaked}"

if os.name == "nt":
    unexpected_archives = [
        str(path)
        for path in owned_files
        if path.suffix.lower() == ".lib"
        and not path.name.lower().startswith("rtabmap_")
    ]
else:
    unexpected_archives = [str(path) for path in owned_files if path.suffix == ".a"]
assert not unexpected_archives, f"unexpected static archives: {unexpected_archives}"

cmake_root = prefix / ("Library/lib" if os.name == "nt" else "lib")
cmake_files = list(cmake_root.glob("rtabmap-*/*.cmake"))
assert cmake_files, "installed CMake package metadata was not found"
forbidden_cmake_fragments = (
    "/tmp/",
    "/bld/",
    "\\\\bld\\\\",
    "conda-bld",
    "host_env",
    "build_env",
    "rattler-build_",
)
cmake_leaks = []
for path in cmake_files:
    text = path.read_text(encoding="utf-8")
    # Prefix relocation is expected for CMake files tagged with [prefix:text].
    # Remove the active test prefix, while retaining checks for every other
    # build or host path that may have leaked from the package build.
    for prefix_spelling in (str(prefix), prefix.as_posix()):
        text = text.replace(prefix_spelling, "")
    if any(fragment in text for fragment in forbidden_cmake_fragments):
        cmake_leaks.append(str(path.relative_to(prefix)))
assert not cmake_leaks, f"build paths leaked into CMake metadata: {cmake_leaks}"

include_root = prefix / ("Library/include" if os.name == "nt" else "include")
version_header = include_root / "rtabmap-0.23/rtabmap/core/Version.h"
version_text = version_header.read_text(encoding="utf-8")


def macro_is_defined(name: str) -> bool:
    pattern = rf"^#define[ \t]+{re.escape(name)}(?:[ \t]|$)"
    return re.search(pattern, version_text, re.MULTILINE) is not None

for macro in (
    "RTABMAP_APRILTAG",
    "RTABMAP_CERES",
    "RTABMAP_OCTOMAP",
    "RTABMAP_PDAL",
    "RTABMAP_REALSENSE2",
):
    assert macro_is_defined(macro), f"{macro} was not enabled"

if os.name != "nt":
    assert macro_is_defined("RTABMAP_DC1394"), "RTABMAP_DC1394 was not enabled"

for macro in (
    "RTABMAP_G2O",
    "RTABMAP_GTSAM",
    "RTABMAP_MADGWICK",
    "RTABMAP_OPENGV",
    "RTABMAP_ORB_OCTREE",
    "RTABMAP_PYTHON",
    "RTABMAP_TORO",
    "RTABMAP_VERTIGO",
):
    assert not macro_is_defined(macro), f"{macro} was unexpectedly enabled"
