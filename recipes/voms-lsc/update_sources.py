#!/usr/bin/env python3
"""Update recipe.yaml source section with latest VOMS RPM URLs from WLCG repodata."""

import gzip
import hashlib
import re
import xml.etree.ElementTree as ET
from pathlib import Path

import requests

BASE_URL = "https://linuxsoft.cern.ch/wlcg/el9/x86_64/"
RECIPE_PATH = Path(__file__).parent / "recipe.yaml"

# RPM name prefixes that identify VOMS-related packages.
# Note: "wlcg-voms-" matches wlcg-voms-alice etc but NOT wlcg-vomses-belle (different prefix).
VOMS_RPM_PREFIXES = (
    "desy-voms-all",
    "wlcg-iam-lsc-",
    "wlcg-iam-vomses-",
    "wlcg-voms-",
    "wlcg-vomses-",
    "wlcg-lsc-",
)


def is_voms_rpm(name: str) -> bool:
    return any(name.startswith(prefix) for prefix in VOMS_RPM_PREFIXES)


def version_key(ver: str, rel: str, epoch: str) -> tuple:
    """Return a sortable tuple for RPM version comparison."""
    def to_ints(s: str) -> tuple:
        # Split on non-numeric boundaries, keep only leading numeric parts
        parts = re.split(r"[^0-9]+", s.split(".")[0])
        try:
            return tuple(int(p) for p in parts if p)
        except ValueError:
            return (0,)

    ep = int(epoch) if epoch else 0
    # For version like "3.0.0", split on dots and convert
    try:
        ver_parts = tuple(int(x) for x in ver.split("."))
    except ValueError:
        ver_parts = (0,)
    # Release like "1.el9" — use only leading numeric part
    try:
        rel_parts = tuple(int(x) for x in rel.split(".el")[0].split("."))
    except ValueError:
        rel_parts = (0,)
    return (ep, ver_parts, rel_parts)


def fetch_primary_xml() -> ET.Element:
    print(f"Fetching repomd.xml ...")
    resp = requests.get(BASE_URL + "repodata/repomd.xml")
    resp.raise_for_status()
    root = ET.fromstring(resp.content)

    primary_href = None
    for elem in root:
        if elem.attrib.get("type") == "primary":
            location = elem.find("{http://linux.duke.edu/metadata/repo}location")
            primary_href = location.attrib["href"]
            break

    if primary_href is None:
        raise RuntimeError("Could not find primary XML location in repomd.xml")

    primary_url = BASE_URL + primary_href
    print(f"Fetching primary XML ...")
    resp = requests.get(primary_url)
    resp.raise_for_status()

    return ET.fromstring(gzip.decompress(resp.content))


def get_latest_voms_rpms(primary_root: ET.Element) -> dict:
    """Return {name: (location_href, sha256)} for the latest version of each VOMS RPM."""
    ns = "http://linux.duke.edu/metadata/common"
    # Track: name -> (ver_key, location_href, checksum)
    latest: dict = {}

    for pkg in primary_root.findall(f"{{{ns}}}package"):
        arch_elem = pkg.find(f"{{{ns}}}arch")
        if arch_elem is not None and arch_elem.text == "src":
            continue

        name_elem = pkg.find(f"{{{ns}}}name")
        if name_elem is None:
            continue
        name = name_elem.text
        if not is_voms_rpm(name):
            continue

        version_elem = pkg.find(f"{{{ns}}}version")
        location_elem = pkg.find(f"{{{ns}}}location")
        checksum_elem = pkg.find(f"{{{ns}}}checksum")

        ver = version_elem.attrib["ver"]
        rel = version_elem.attrib["rel"]
        epoch = version_elem.attrib.get("epoch", "0")
        href = location_elem.attrib["href"]

        # Use sha256 checksum from primary XML if available (avoids downloading)
        checksum = None
        if checksum_elem is not None and checksum_elem.attrib.get("type") == "sha256":
            checksum = checksum_elem.text

        key = version_key(ver, rel, epoch)
        if name not in latest or key > latest[name][0]:
            latest[name] = (key, href, checksum)

    return {name: (href, checksum) for name, (_, href, checksum) in latest.items()}


def get_sha256(url: str, provided: str | None) -> str:
    """Use provided sha256 if available, otherwise download and compute."""
    if provided:
        return provided
    print(f"  Downloading {url.split('/')[-1]} for sha256 ...")
    resp = requests.get(url)
    resp.raise_for_status()
    return hashlib.sha256(resp.content).hexdigest()


def update_recipe(rpm_entries: list[str], recipe_path: Path) -> None:
    raw = recipe_path.read_text()

    # Find the source: block (all lines with 2+ leading spaces after "source:")
    source_match = re.search(r"^source:\n((?:  .*\n)*)", raw, re.MULTILINE)
    if not source_match:
        raise ValueError("Could not find source: section in recipe.yaml")

    source_block = source_match.group(1)

    # Split into individual source entries; each entry starts with "  - "
    raw_entries = re.split(r"(?=  - )", source_block)

    # Keep only path: entries (non-RPM VOs that stay as local files)
    path_entries = [e for e in raw_entries if re.search(r"path:", e) and e.strip()]

    new_source = "source:\n"
    new_source += "\n".join(rpm_entries) + "\n"
    if path_entries:
        new_source += "".join(path_entries)

    start, end = source_match.span()
    recipe_path.write_text(raw[:start] + new_source + raw[end:])
    print(f"Updated {recipe_path}")


def main():
    primary_root = fetch_primary_xml()
    latest = get_latest_voms_rpms(primary_root)

    print(f"\nFound {len(latest)} VOMS RPMs:")
    rpm_entries = []
    for name in sorted(latest):
        href, checksum = latest[name]
        url = BASE_URL + href
        sha256 = get_sha256(url, checksum)
        print(f"  {name}: {sha256[:16]}...")
        rpm_entries.append(
            f"  - url: {url}\n    sha256: {sha256}\n    target_directory: rpms"
        )

    update_recipe(rpm_entries, RECIPE_PATH)
    print("\nDone. Review recipe.yaml, then run rattler-build to test.")


if __name__ == "__main__":
    main()
