#!/usr/bin/env python3
"""Generate the .dist-info metadata that lets ``pip check`` catch dependency drift.

The recipe installs each bundled Isaac Lab package with ``pip install --no-deps``,
so the resulting metadata carries no third-party requirements and ``pip check``
has nothing to validate. This script rebuilds that metadata from the dependency
set upstream's ``tools/wheel_builder/gen_pyproject.py`` writes to ``gen_deps.toml``.

The ``base`` subcommand reinjects the core third-party requirements into the
installed ``isaaclab`` metadata, and strips the closed-source ones that some
members pin (for example ``isaaclab_ov`` depends on ``ovstage``).

The ``extra`` subcommand handles the optional-dependency metapackages. Since
``pip check`` ignores ``; extra == "..."`` markers, it writes for each extra a
synthetic ``isaaclab-extra-<name>`` dist-info whose ``Requires-Dist`` lists that
extra's dependencies. The prefix keeps the name distinct from a real member such
as ``isaaclab_mimic``.

Requirements are recorded by name only, without versions, because conda-forge
usually serves builds newer than the ones upstream pins.
"""

from __future__ import annotations

import glob
import os
import re
import sys

import tomllib

# Names with no conda-forge package (closed-source Omniverse wheels or
# integrations shipped only from Git).
MISSING = {
    "isaacsim",
    "isaacsim-asset-isolated",
    "isaacteleop",
    "omniverseclient",
    "ovphysx",
    "ovrtx",
    "ovstage",
    "rl-games",
    "skrl",
    "standard-distutils",
}

# Git-only deps gen_pyproject.py drops but that have a feedstock. The recipe
# ships them, so re-add them by name (Git URL stripped) for pip check.
KEEP_GIT = {
    "robomimic",
}

USAGE = (
    "usage:\n"
    "    gen_extra_metadata.py base <gen_deps.toml> <site-packages>\n"
    "    gen_extra_metadata.py extra <gen_deps.toml> <root_pyproject.toml>"
    " <site-packages> <extra> <version>"
)


def dist_name(requirement: str) -> str:
    """Normalized distribution name of a PEP 508 requirement string."""
    name = re.split(r"[\s<>=!~;\[@]", requirement.strip(), maxsplit=1)[0]
    return name.strip().lower().replace("_", "-")


def load_deps(path: str, group: str | None = None) -> list[str]:
    """Core dependencies, or one optional-dependencies group, from a pyproject."""
    with open(path, "rb") as handle:
        project = tomllib.load(handle)["project"]
    if group is None:
        return project.get("dependencies", [])
    return project.get("optional-dependencies", {}).get(group, [])


def cmd_base(gen_deps_path: str, site_packages: str) -> None:
    names = sorted({dist_name(d) for d in load_deps(gen_deps_path)} - MISSING)

    for meta in glob.glob(os.path.join(site_packages, "isaaclab*.dist-info", "METADATA")):
        kept = [
            line
            for line in open(meta, encoding="utf-8").read().splitlines()
            if not (line.startswith("Requires-Dist:") and dist_name(line.split(":", 1)[1]) in MISSING)
        ]
        open(meta, "w", encoding="utf-8").write("\n".join(kept) + "\n")

    core = glob.glob(os.path.join(site_packages, "isaaclab-*.dist-info", "METADATA"))[0]
    lines = open(core, encoding="utf-8").read().splitlines()
    i = lines.index("") if "" in lines else len(lines)
    lines[i:i] = [f"Requires-Dist: {name}" for name in names]
    open(core, "w", encoding="utf-8").write("\n".join(lines) + "\n")
    print(f"isaaclab: injected {len(names)} Requires-Dist")


def cmd_extra(
    gen_deps_path: str, root_pyproject_path: str, site_packages: str, extra: str, version: str
) -> None:
    names = {dist_name(d) for d in load_deps(gen_deps_path, extra)}
    # Re-add the conda-available Git deps gen_pyproject.py stripped.
    names |= {name for d in load_deps(root_pyproject_path, extra) if (name := dist_name(d)) in KEEP_GIT}
    names = sorted(names - MISSING)

    dist = f"isaaclab-extra-{extra}"
    dist_info = os.path.join(site_packages, f"{dist.replace('-', '_')}-{version}.dist-info")
    os.makedirs(dist_info, exist_ok=True)
    metadata = ["Metadata-Version: 2.1", f"Name: {dist}", f"Version: {version}"]
    metadata += [f"Requires-Dist: {name}" for name in names]
    open(os.path.join(dist_info, "METADATA"), "w", encoding="utf-8").write("\n".join(metadata) + "\n")
    # An empty RECORD is enough for pip to treat the directory as installed.
    open(os.path.join(dist_info, "RECORD"), "w", encoding="utf-8").write("")
    print(f"{dist}: wrote {len(names)} Requires-Dist ({', '.join(names) or 'none'})")


def main() -> int:
    args = sys.argv[1:]
    if len(args) >= 3 and args[0] == "base" and len(args) == 3:
        cmd_base(args[1], args[2])
    elif len(args) == 6 and args[0] == "extra":
        cmd_extra(args[1], args[2], args[3], args[4], args[5])
    else:
        print(USAGE, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
