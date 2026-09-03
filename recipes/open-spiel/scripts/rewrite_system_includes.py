"""Rewrite OpenSpiel's bundled-library include prefixes for system packages."""

from pathlib import Path


REPLACEMENTS = {
    "open_spiel/abseil-cpp/absl/": ("absl/", 937),
    "open_spiel/json/include/nlohmann/": ("nlohmann/", 35),
    "open_spiel/pybind11_json/include/pybind11_json/": ("pybind11_json/", 4),
    "pybind11/include/pybind11/": ("pybind11/", 36),
}

root = Path("open_spiel")
sources = tuple(root.rglob("*.cc")) + tuple(root.rglob("*.h"))
counts = {old: 0 for old in REPLACEMENTS}

for path in sources:
    contents = path.read_text(encoding="utf-8")
    updated = contents
    for old, (new, _) in REPLACEMENTS.items():
        counts[old] += updated.count(old)
        updated = updated.replace(old, new)
    if updated != contents:
        path.write_text(updated, encoding="utf-8")

expected = {old: count for old, (_, count) in REPLACEMENTS.items()}
if counts != expected:
    raise RuntimeError(f"Unexpected include-prefix counts: {counts}; expected {expected}")

for old in REPLACEMENTS:
    remaining = [str(path) for path in sources if old in path.read_text(encoding="utf-8")]
    if remaining:
        raise RuntimeError(f"Bundled include prefix {old!r} remains in: {remaining}")
