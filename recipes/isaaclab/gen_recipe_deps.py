#!/usr/bin/env -S pixi run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["rich"]
# ///
# Run with: pixi run --script gen_recipe_deps.py -- --rev release/3.0.0 [--extras]
# tomllib + urllib are stdlib; rich renders the tables.

"""Print the third-party dependency set for the ``isaaclab`` recipe from upstream.

The published ``isaaclab`` wheel bundles every ``isaaclab*`` extension into a
single distribution, so its runtime dependencies are exactly the third-party
entries of the root ``pyproject.toml`` (workspace self-references stripped),
plus the per-extra groups. This reproduces the logic of upstream
``tools/wheel_builder/gen_pyproject.py`` against an arbitrary revision, then maps
the PyPI names to their conda-forge equivalents and flags the ones that are still
missing, so the maintainer can reconcile ``recipe.yaml`` without scraping a build
log.

Usage:
    pixi run --script gen_recipe_deps.py -- --rev release/3.0.0
    pixi run --script gen_recipe_deps.py -- --rev <sha> --no-extras
"""

from __future__ import annotations

import argparse
import re
import sys
import urllib.error
import urllib.request
from typing import TypedDict, cast

import tomllib
from rich import box
from rich.console import Console
from rich.panel import Panel
from rich.table import Table

_Project = TypedDict(
    "_Project",
    {
        "name": str,
        "dependencies": list[str],
        "optional-dependencies": dict[str, list[str]],
    },
)


class _PyProject(TypedDict):
    project: _Project


RAW_URL = "https://raw.githubusercontent.com/isaac-sim/IsaacLab/{rev}/pyproject.toml"

# PyPI distribution name -> conda-forge package name (only where they differ).
PYPI_TO_CONDA = {
    "dm_tree": "dm-tree",
    "lazy_loader": "lazy-loader",
    "matplotlib": "matplotlib-base",
    "newton": "newton-sim",  # the ``[sim]`` extra maps to the conda ``newton-sim``
    "pin": "pinocchio",
    "pin-pink": "pink",
    "ray": "ray-default",  # ``ray[default]`` -> conda ``ray-default``
    "torch": "pytorch",
}

# Normalized PyPI names with no conda-forge package (as of the last review).
# Keep these commented in recipe.yaml until a feedstock exists.
MISSING_ON_CONDA_FORGE = {
    "isaacsim",
    "isaacsim-asset-isolated",
    "isaacteleop",
    "leapp",
    "omniverseclient",
    "ovphysx",
    "ovrtx",
    "ovstage",
    "pytetwild",
    "rl-games",
    "skrl",
    "standard-distutils",
}


def _normalize(name: str) -> str:
    return re.sub(r"[-_.]+", "-", name).lower()


def _requirement_name(requirement: str) -> str:
    name = re.split(r"\s|<|>|=|!|~|\[|@|;", requirement, maxsplit=1)[0].strip()
    return _normalize(name)


def _is_workspace_member(requirement: str) -> bool:
    return _requirement_name(requirement).startswith("isaaclab")


def _load_pyproject(rev: str) -> _PyProject:
    url = RAW_URL.format(rev=rev)
    try:
        with urllib.request.urlopen(url, timeout=30) as response:  # pyright: ignore[reportAny]
            text = response.read().decode("utf-8")  # pyright: ignore[reportAny]
    except urllib.error.URLError as exc:
        raise SystemExit(f"error: could not fetch {url}: {exc.reason}") from exc
    return cast("_PyProject", cast("object", tomllib.loads(text)))  # pyright: ignore[reportAny]


def _self_ref_extras(requirement: str, project_name: str) -> list[str] | None:
    match = re.match(r"^\s*([A-Za-z0-9._-]+)\s*\[([^\]]+)\]\s*$", requirement)
    if match is None or _normalize(match.group(1)) != project_name:
        return None
    return [extra.strip() for extra in match.group(2).split(",")]


def _expand_self_refs(
    reqs: list[str],
    optional: dict[str, list[str]],
    project_name: str,
    seen: set[str] | None = None,
) -> list[str]:
    seen = set() if seen is None else seen
    out: list[str] = []
    for requirement in reqs:
        extras = _self_ref_extras(requirement, project_name)
        if extras is None:
            out.append(requirement)
            continue
        for extra in extras:
            if extra in seen:
                continue
            seen.add(extra)
            out.extend(
                _expand_self_refs(optional.get(extra, []), optional, project_name, seen)
            )
    return out


def _dedup(reqs: list[str]) -> list[str]:
    seen: set[str] = set()
    out: list[str] = []
    for requirement in reqs:
        key = _requirement_name(requirement)
        if key not in seen:
            seen.add(key)
            out.append(requirement)
    return out


def _conda_name(requirement: str) -> str:
    name = _requirement_name(requirement)
    return PYPI_TO_CONDA.get(name, name)


def _status(requirement: str) -> str:
    return (
        "MISSING" if _requirement_name(requirement) in MISSING_ON_CONDA_FORGE else "ok"
    )


def _display(requirement: str) -> str:
    return requirement.split(";", 1)[0].strip()


def _make_table(title: str, requirements: list[str]) -> Panel:
    table = Table(box=box.SIMPLE_HEAD, header_style="bold", pad_edge=False)
    table.add_column("PyPI requirement")
    table.add_column("conda-forge")
    table.add_column("status")
    all_available = True
    for requirement in requirements:
        status = _status(requirement)
        if status == "MISSING":
            all_available = False
        style = "red" if status == "MISSING" else "green"
        table.add_row(
            _display(requirement),
            _conda_name(requirement),
            f"[{style}]{status}[/{style}]",
        )
    color = "green" if all_available else "red"
    return Panel(
        table,
        title=f"[{color}]{title}[/{color}]",
        title_align="left",
        border_style=color,
        padding=(0, 1),
        expand=False,
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    _ = parser.add_argument(
        "--rev", required=True, help="IsaacLab git ref (branch, tag or SHA)."
    )
    _ = parser.add_argument(
        "--extras",
        action=argparse.BooleanOptionalAction,
        default=True,
        help="Print every optional-dependency group after the core (default: on; use --no-extras to skip).",
    )
    _ = parser.add_argument(
        "--extra",
        action="append",
        default=[],
        metavar="NAME",
        help="Print only the given extra group (repeatable). Implies --extras for that group.",
    )
    args = parser.parse_args()
    rev = cast("str", args.rev)
    want_extras = cast("bool", args.extras)
    want_extra = cast("list[str]", args.extra)

    root = _load_pyproject(rev)
    project = root["project"]
    project_name = _normalize(project["name"])
    optional = project.get("optional-dependencies", {})
    dependencies = project["dependencies"]

    console = Console()

    if want_extra:
        unknown = [name for name in want_extra if name not in optional]
        if unknown:
            parser.error(
                f"unknown extra(s): {', '.join(unknown)}. Available: {', '.join(optional)}"
            )
        selected = list(want_extra)
    else:
        core = _dedup(
            [
                d
                for d in _expand_self_refs(dependencies, optional, project_name)
                if not _is_workspace_member(d)
            ]
        )
        console.print(
            _make_table(f"isaaclab core run deps @ {rev}  ({len(core)} entries)", core)
        )
        selected = list(optional) if want_extras else []

    for name in selected:
        deps = _dedup(
            [
                d
                for d in _expand_self_refs(optional[name], optional, project_name)
                if not _is_workspace_member(d)
            ]
        )
        console.print(_make_table(f"extra: {name}  ({len(deps)} entries)", deps))

    return 0


if __name__ == "__main__":
    sys.exit(main())
