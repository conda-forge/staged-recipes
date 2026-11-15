"""Combine NuGet and supplemental notices, storing identical bytes only once."""

import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import tarfile
import zipfile


LICENSE_NAME = re.compile(
    r"(?:licen[sc]es?|copying|notices?|third[-_ .]?party[-_ .]?(?:notices?|licenses?))"
    r"(?:[._-].*)?",
    re.IGNORECASE,
)


def is_notice(name):
    parts = PurePosixPath(name.replace("\\", "/")).parts
    return any(LICENSE_NAME.fullmatch(part) for part in parts)


def collect(nuget_packages, appdir, source_licenses, output,
            source_dir, runtime_id):
    output.mkdir(parents=True, exist_ok=True)
    texts = output / "texts"
    texts.mkdir(exist_ok=True)
    # A repeated collection must not leave documents from an earlier build.
    for path in texts.iterdir():
        path.unlink()
    entries = []
    # Core Tools' own license is packaged directly by license_file.
    core_license = (source_dir / "LICENSE").read_bytes()
    documents = {hashlib.sha256(core_license).hexdigest(): "../LICENSE"}

    def save(data, origin):
        if not data:
            raise ValueError(f"Empty license document: {origin}")
        digest = hashlib.sha256(data).hexdigest()
        suffix = PurePosixPath(origin).suffix.lower()
        if suffix not in {".html", ".htm", ".md", ".txt"}:
            suffix = ".txt"
        if digest not in documents:
            documents[digest] = "texts/" + digest + suffix
            (output / documents[digest]).write_bytes(data)
        entries.append((origin, documents[digest], digest))

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
    policy = json.loads((source_dir / "LICENSE_POLICY.json").read_text(encoding="utf-8"))
    accent = (nuget_packages / "accentedcommandlineparser" /
              policy["reviewed_packages"]["accentedcommandlineparser"] /
              "lib/netstandard2.0/LICENCE.txt")
    save(accent.read_bytes(), "nuget/" + accent.relative_to(nuget_packages).as_posix())

    has_uvloop = any((appdir / "workers/python").rglob("uvloop/__init__.py"))
    sources = sorted(path for path in source_licenses.rglob("*") if path.is_file())
    if not sources:
        raise ValueError("Missing supplemental license sources")
    # rattler-build verifies every raw document and archive against recipe.yaml.
    for path in sources:
        relative = path.relative_to(source_licenses).as_posix()
        component = relative.split("/", 1)[0]
        # The Windows Python worker does not bundle uvloop/libuv.
        if component == "uvloop" and not has_uvloop:
            continue
        origin = "source/" + relative
        count = len(entries)
        if path.name.endswith(".tar.gz"):
            # Collect top-level licenses, plus required libuv/dateutil notices.
            # Do not include libuv's documentation-only license or build tools.
            allowed = {
                "uvloop": {"LICENSE-MIT", "LICENSE-APACHE", "vendor/libuv/LICENSE",
                           "vendor/libuv/LICENSE-extra", "vendor/libuv/AUTHORS"},
                "python-dateutil": {"LICENSE", "AUTHORS.md"},
            }.get(component, {"LICENSE", "LICENSE.txt"})
            with tarfile.open(path) as archive:
                for member in archive.getmembers():
                    name = member.name.partition("/")[2]
                    if member.isfile() and name in allowed:
                        save(archive.extractfile(member).read(), origin + "!/" + member.name)
        else:
            save(path.read_bytes(), origin)
        if len(entries) == count:
            raise ValueError(f"No license documents found in {path}")

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

    rows = [
        "# License documents",
        "",
        "Collected from Core Tools/templates, NuGet license downloads, the bundled",
        ".NET runtime packs, AccentedCommandLineParser, published workers, and the",
        "versioned upstream sources whose URLs and checksums are in recipe.yaml.",
        "Identical documents share a file. Every original path is retained below.",
        "See THIRD_PARTY_NUGET_LICENSES.md for NuGet metadata and LICENSE_POLICY.json",
        "for the exact unresolved packages and source-backed metadata corrections.",
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
    for name in ["nuget-packages", "appdir", "source-licenses", "output", "source-dir"]:
        parser.add_argument("--" + name, type=Path, required=True)
    parser.add_argument("--runtime-id", required=True)
    args = parser.parse_args()
    collect(args.nuget_packages, args.appdir, args.source_licenses, args.output,
            args.source_dir, args.runtime_id)
