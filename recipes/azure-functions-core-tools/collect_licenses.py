"""Collect notices omitted from NuGet license metadata, without downloading files."""

import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import zipfile


LICENSE_NAME = re.compile(
    r"(?:licen[sc]es?|copying|notices?|third[-_ .]?party[-_ .]?(?:notices?|licenses?))"
    r"(?:[._-].*)?",
    re.IGNORECASE,
)


def is_notice(name):
    parts = PurePosixPath(name.replace("\\", "/")).parts
    return any(LICENSE_NAME.fullmatch(part) for part in parts)


def collect(nuget_packages, appdir, source_licenses, manifest_path, output):
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    for package, version in manifest["nuget_packages"].items():
        if not (nuget_packages / package / version).is_dir():
            raise ValueError(f"Missing {package}/{version}; review the pinned license sources")

    output.mkdir(parents=True, exist_ok=True)
    texts = output / "texts"
    texts.mkdir(exist_ok=True)
    entries = []

    def save(data, origin):
        if not data:
            raise ValueError(f"Empty license document: {origin}")
        digest = hashlib.sha256(data).hexdigest()
        suffix = PurePosixPath(origin).suffix.lower()
        if suffix not in {".html", ".htm", ".md", ".txt"}:
            suffix = ".txt"
        target = texts / (digest + suffix)
        if not target.exists():
            target.write_bytes(data)
        entries.append((origin, target.relative_to(output).as_posix(), digest))

    for item in manifest["sources"]:
        path = source_licenses / item["file"]
        if not path.resolve().is_relative_to(source_licenses.resolve()):
            raise ValueError(f"Invalid source path: {item['file']}")
        data = path.read_bytes()
        if hashlib.sha256(data).hexdigest() != item["sha256"]:
            raise ValueError(f"License checksum mismatch: {item['file']}")
        save(data, "upstream/" + item["file"])

    # Include LICENCE as well as LICENSE. For example, AccentedCommandLineParser
    # stores lib/netstandard2.0/LICENCE.txt without declaring it in its nuspec.
    # Preserve the notices inside license directories, including Java JARs.
    for label, root in [("nuget", nuget_packages), ("published", appdir / "workers")]:
        if not root.is_dir():
            raise ValueError(f"Expected license input directory: {root}")
        for path in sorted(root.rglob("*")):
            if not path.is_file() or path.is_symlink():
                continue
            relative = path.relative_to(root).as_posix()
            origin = label + "/" + relative
            if is_notice(relative):
                save(path.read_bytes(), origin)
            elif path.suffix.lower() == ".jar":
                with zipfile.ZipFile(path) as archive:
                    for member in sorted(archive.namelist()):
                        if not member.endswith("/") and is_notice(member):
                            save(archive.read(member), origin + "!/" + member)

    (output / "SOURCES.json").write_text(
        json.dumps(manifest, indent=2) + "\n", encoding="utf-8"
    )
    rows = [
        "# Additional third-party license documents",
        "",
        "Collected from restored NuGet packages, published workers, and the",
        "versioned upstream sources recorded in [SOURCES.json](SOURCES.json).",
        "Identical documents share a file; every original path is retained below.",
        "See the separate THIRD_PARTY_NUGET_LICENSES.md for NuGet metadata and",
        "LICENSE_REVIEW.md for unresolved licensing questions.",
        "",
        "| Original document | Packaged text | SHA-256 |",
        "| --- | --- | --- |",
    ]
    for origin, target, digest in sorted(set(entries)):
        rows.append(f"| `{origin}` | [text]({target}) | `{digest}` |")
    (output / "INDEX.md").write_text("\n".join(rows) + "\n", encoding="utf-8")
    print(f"Collected {len(set(entries))} license references into {len(list(texts.iterdir()))} documents")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ["nuget-packages", "appdir", "source-licenses", "manifest", "output"]:
        parser.add_argument("--" + name, type=Path, required=True)
    args = parser.parse_args()
    collect(args.nuget_packages, args.appdir, args.source_licenses, args.manifest, args.output)
