"""Limit license exceptions to reviewed package versions in the resolved graph."""

import json
from pathlib import Path
import sys


def prepare(policy_path, assets_path, output):
    policy = json.loads(policy_path.read_text(encoding="utf-8"))
    assets = json.loads(assets_path.read_text(encoding="utf-8"))
    resolved = {
        name.lower(): version
        for key, metadata in assets["libraries"].items()
        if metadata["type"] == "package"
        for name, version in [key.rsplit("/", 1)]
    }
    expected = dict(policy["reviewed_packages"])
    expected.update(policy["unresolved_packages"])
    expected.update({item["Id"].lower(): item["Version"] for item in policy["overrides"]})
    for name, version in expected.items():
        if resolved.get(name) != version:
            raise ValueError(f"Review license sources and exceptions for {name}: "
                             f"expected {version}, resolved {resolved.get(name)}")
    output.mkdir(parents=True, exist_ok=True)
    for name, data in [("ignored-packages.json", list(policy["unresolved_packages"])),
                       ("license-overrides.json", policy["overrides"]),
                       ("LICENSE_POLICY.json", policy)]:
        (output / name).write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    prepare(Path(sys.argv[1]), Path(sys.argv[2].strip()), Path(sys.argv[3]))
