"""Combine NuGet and supplemental notices, storing identical bytes only once."""

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


def collect(nuget_packages, appdir, source_licenses, manifest_path, output,
            source_dir, runtime_id):
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    for package, version in manifest["nuget_packages"].items():
        if not (nuget_packages / package / version).is_dir():
            raise ValueError(f"Missing {package}/{version}; review the pinned license sources")

    output.mkdir(parents=True, exist_ok=True)
    texts = output / "texts"
    texts.mkdir(exist_ok=True)
    # A repeated collection must not leave documents from an earlier build.
    for path in texts.iterdir():
        path.unlink()
    entries = []
    documents = {}

    def save(data, origin):
        if not data:
            raise ValueError(f"Empty license document: {origin}")
        digest = hashlib.sha256(data).hexdigest()
        suffix = PurePosixPath(origin).suffix.lower()
        if suffix not in {".html", ".htm", ".md", ".txt"}:
            suffix = ".txt"
        target = documents.setdefault(digest, texts / (digest + suffix))
        if not target.exists():
            target.write_bytes(data)
        entries.append((origin, target.relative_to(output).as_posix(), digest))

    # Use one content store for the original recipe inputs and the supplements.
    # Otherwise NuGet downloads and runtime-pack notices bypass deduplication.
    for name in ["LICENSE", "AZURE_FUNCTIONS_TEMPLATES_LICENSE.txt"]:
        save((source_dir / name).read_bytes(), "source/" + name)
    downloads = source_dir / "nuget-licenses"
    if not downloads.is_dir():
        raise ValueError(f"Missing NuGet license downloads: {downloads}")
    for path in sorted(downloads.rglob("*")):
        if path.is_file():
            save(path.read_bytes(), "nuget-download/" + path.relative_to(downloads).as_posix())

    # Select the runtime packs actually bundled in this self-contained publish,
    # excluding SDK/reference packs and other platforms/versions in the cache.
    config = json.loads((appdir / "func.runtimeconfig.json").read_text(encoding="utf-8"))
    frameworks = config["runtimeOptions"]["includedFrameworks"]
    for framework in frameworks:
        package = framework["name"].lower() + ".runtime." + runtime_id
        root = nuget_packages / package / framework["version"]
        for pattern in ["LICENSE.*", "THIRD-PARTY-NOTICES.*"]:
            matches = sorted(root.glob(pattern))
            if not matches:
                raise ValueError(f"Missing bundled runtime notice: {root}/{pattern}")
            for path in matches:
                save(path.read_bytes(), "nuget/" + path.relative_to(nuget_packages).as_posix())

    # This is the known NuGet metadata gap with an embedded license document.
    accent = (nuget_packages / "accentedcommandlineparser" /
              manifest["nuget_packages"]["accentedcommandlineparser"] /
              "lib/netstandard2.0/LICENCE.txt")
    save(accent.read_bytes(), "nuget/" + accent.relative_to(nuget_packages).as_posix())

    has_uvloop = any((appdir / "workers/python").rglob("uvloop/__init__.py"))
    packaged_sources = []
    for item in manifest["sources"]:
        path = source_licenses / item["file"]
        if not path.resolve().is_relative_to(source_licenses.resolve()):
            raise ValueError(f"Invalid source path: {item['file']}")
        data = path.read_bytes()
        if hashlib.sha256(data).hexdigest() != item["sha256"]:
            raise ValueError(f"License checksum mismatch: {item['file']}")
        # The Windows Python worker does not bundle uvloop/libuv.
        if item["component"] == "uvloop" and not has_uvloop:
            continue
        packaged_sources.append(item)
        # Keep component/version attribution even when several sources share
        # the same snapshot file in the recipe.
        save(data, f"upstream/{item['component']}/{item['version']}: {item['url']}"
             + ("!/" + item["archive_member"] if "archive_member" in item else ""))

    # Inspect only published workers, not the entire restored NuGet cache:
    # the latter also contains build-only packages and unselected worker assets.
    for label, root in [("published", appdir / "workers")]:
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

    manifest["sources"] = packaged_sources
    (output / "SOURCES.json").write_text(
        json.dumps(manifest, indent=2) + "\n", encoding="utf-8"
    )
    rows = [
        "# License documents",
        "",
        "Collected from Core Tools/templates, NuGet license downloads, the bundled",
        ".NET runtime packs, AccentedCommandLineParser, published workers, and the",
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
    for name in ["nuget-packages", "appdir", "source-licenses", "manifest", "output", "source-dir"]:
        parser.add_argument("--" + name, type=Path, required=True)
    parser.add_argument("--runtime-id", required=True)
    args = parser.parse_args()
    collect(args.nuget_packages, args.appdir, args.source_licenses, args.manifest,
            args.output, args.source_dir, args.runtime_id)
