"""Manage PV_PLUGIN_PATH for the active IMAS-ParaView conda environment."""

import hashlib
import os
import sys
import sysconfig
from pathlib import Path


def plugin_dir() -> str:
    return str(Path(sysconfig.get_path("purelib")) / "imas_paraview" / "plugins")


def elements() -> list[str]:
    return [p for p in os.environ.get("PV_PLUGIN_PATH", "").split(os.pathsep) if p]


def same(a: str, b: str) -> bool:
    if os.name == "nt":
        return os.path.normcase(os.path.normpath(a)) == os.path.normcase(
            os.path.normpath(b)
        )
    return os.path.normpath(a) == os.path.normpath(b)


def state_key() -> str:
    # Stacked environments must retain independent ownership of their paths.
    prefix = os.path.normcase(os.path.normpath(sys.prefix))
    digest = hashlib.sha256(os.fsencode(prefix)).hexdigest()
    return f"_IMAS_PARAVIEW_PVPATH_ADDED_{digest}"


def main() -> None:
    if len(sys.argv) != 2 or sys.argv[1] not in (
        "path",
        "contains",
        "add",
        "remove",
        "key",
        "owned",
    ):
        raise SystemExit(
            "usage: imas-paraview-pvpath.py {path|contains|add|remove|key|owned}"
        )
    action = sys.argv[1]
    path = plugin_dir()
    paths = elements()
    if action == "path":
        print(path)
    elif action == "key":
        print(state_key())
    elif action == "owned":
        sys.exit(0 if os.environ.get(state_key()) == "1" else 1)
    elif action == "contains":
        sys.exit(0 if any(same(p, path) for p in paths) else 1)
    elif action == "add":
        if not any(same(p, path) for p in paths):
            paths.insert(0, path)
        print(os.pathsep.join(paths))
    else:
        # Remove only one occurrence (normally the one we prepended).
        for i, item in enumerate(paths):
            if same(item, path):
                paths.pop(i)
                break
        print(os.pathsep.join(paths))


if __name__ == "__main__":
    main()
