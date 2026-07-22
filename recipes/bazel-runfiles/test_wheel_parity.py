"""Verify the installed package matches the wheel upstream builds with Bazel.

Upstream publishes a Bazel-built wheel to PyPI, while this recipe rebuilds the
same sources with setuptools and a vendored pyproject.toml. Compare the
installed payload byte-for-byte and the resolver-relevant metadata fields
against the official wheel, so that any upstream packaging change (a new
dependency, file, or constraint) fails the test instead of drifting silently.
"""

import email
import io
import sys
import urllib.request
import zipfile
from importlib.metadata import distribution
from pathlib import Path

import runfiles


def canonical(name):
    return name.replace("_", "-").lower()


def compare_payload(wheel, version, errors):
    """Every non-dist-info file in the wheel must be byte-identical to what
    this package installed, with nothing missing or extra."""
    site_packages = Path(runfiles.__file__).resolve().parent.parent
    wheel_files = {
        name
        for name in wheel.namelist()
        if not name.startswith(f"bazel_runfiles-{version}.dist-info/")
    }
    installed_files = {
        str(path.relative_to(site_packages)).replace("\\", "/")
        for path in (site_packages / "runfiles").rglob("*")
        if path.is_file() and "__pycache__" not in path.parts
    }
    if wheel_files != installed_files:
        errors.append(
            f"payload differs: only in wheel {sorted(wheel_files - installed_files)}, "
            f"only installed {sorted(installed_files - wheel_files)}"
        )
    for name in wheel_files & installed_files:
        if wheel.read(name) != (site_packages / name).read_bytes():
            errors.append(f"{name}: contents differ from the wheel")
    return len(wheel_files)


def compare_metadata(wheel, dist, version, errors):
    """The metadata fields that affect installers and resolvers must match.
    (Metadata-Version, Home-page vs Project-URL, and Summary are generator
    differences with no functional effect and are deliberately not compared.)
    """
    theirs_raw = wheel.read(f"bazel_runfiles-{version}.dist-info/METADATA").decode()
    mine_raw = dist.read_text("METADATA")
    theirs = email.message_from_string(theirs_raw)
    mine = email.message_from_string(mine_raw)

    for field, transform in [
        ("Name", canonical),
        ("Version", None),
        ("Requires-Python", None),
        ("Requires-Dist", None),
        ("Classifier", None),
    ]:
        a = theirs.get_all(field, [])
        b = mine.get_all(field, [])
        if transform:
            a, b = map(transform, a), map(transform, b)
        a, b = sorted(a), sorted(b)
        if a != b:
            errors.append(f"METADATA {field}: wheel={a!r} != installed={b!r}")

    if theirs_raw.partition("\n\n")[2].strip() != mine_raw.partition("\n\n")[2].strip():
        errors.append("METADATA long description differs from the wheel")


def main():
    dist = distribution("bazel-runfiles")
    version = dist.version
    url = (
        "https://pypi.org/packages/py3/b/bazel-runfiles/"
        f"bazel_runfiles-{version}-py3-none-any.whl"
    )
    print(f"Comparing installed package against {url}")
    wheel = zipfile.ZipFile(io.BytesIO(urllib.request.urlopen(url).read()))

    errors = []
    n_files = compare_payload(wheel, version, errors)
    compare_metadata(wheel, dist, version, errors)

    if errors:
        print("\n".join(f"ERROR: {e}" for e in errors))
        return 1
    print(f"OK: installed package matches the upstream wheel ({n_files} payload files)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
