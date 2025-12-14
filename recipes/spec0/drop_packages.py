import sys
import requests
import collections
from datetime import datetime, timedelta

import pandas as pd
from packaging.version import Version, InvalidVersion
from ruamel.yaml import YAML


core_packages = [
    "numpy",
    "scipy",
    "matplotlib",
    "pandas",
    "scikit-image",
    "networkx",
    "scikit-learn",
    "xarray",
    "ipython",
    "zarr",
]
plus24 = timedelta(days=int(365 * 2))

if len(sys.argv) > 1:
    version_str = sys.argv[1]
    year, month = version_str.split(".")
    current_date = pd.Timestamp(int(year), int(month), 1)
else:
    current_date = pd.Timestamp.now()

current_quarter_start = pd.Timestamp(
    current_date.year, (current_date.quarter - 1) * 3 + 1, 1
)
cutoff = current_quarter_start - pd.DateOffset(months=9)


def get_release_dates(package, support_time=plus24):
    releases = {}

    print(f"Querying pypi.org for {package} versions...", end="", flush=True)
    response = requests.get(
        f"https://pypi.org/simple/{package}",
        headers={"Accept": "application/vnd.pypi.simple.v1+json"},
    ).json()
    print("OK")

    file_date = collections.defaultdict(list)
    for f in response["files"]:
        filename = f["filename"]
        if not filename.startswith(f"{package}-"):
            continue
        ver_with_ext = filename[len(f"{package}-"):]
        extensions = [".tar.gz", ".zip", ".tar.bz2", ".whl", ".tar"]
        ver = ver_with_ext
        for ext in extensions:
            if ver_with_ext.endswith(ext):
                ver = ver_with_ext[:-len(ext)]
                break
        else:
            if "." in ver:
                ver = ver.rsplit(".", 1)[0]
        try:
            version = Version(ver)
        except InvalidVersion:
            continue

        if version.is_prerelease or version.micro != 0:
            continue

        release_date = None
        for format in ["%Y-%m-%dT%H:%M:%S.%fZ", "%Y-%m-%dT%H:%M:%SZ"]:
            try:
                release_date = datetime.strptime(f["upload-time"], format)
            except ValueError:
                pass

        if not release_date:
            continue

        file_date[version].append(release_date)

    release_date = {v: min(file_date[v]) for v in file_date}

    for ver, release_date in sorted(release_date.items()):
        drop_date = release_date + support_time
        if drop_date >= cutoff:
            releases[ver] = {
                "release_date": release_date,
                "drop_date": drop_date,
            }

    return releases


package_releases = {package: get_release_dates(package) for package in core_packages}

package_releases = {
    package: {
        version: dates
        for version, dates in releases.items()
        if dates["drop_date"] > current_date
    }
    for package, releases in package_releases.items()
}

minimum_versions = {}
for package, releases in package_releases.items():
    if releases:
        versions = sorted(releases.keys())
        min_version = min(versions)
        minimum_versions[package] = str(min_version)

print("Updating recipe.yaml with minimum versions...")
yaml = YAML()
yaml.preserve_quotes = True
yaml.width = 4096

with open("recipe.yaml", "r") as fh:
    recipe = yaml.load(fh)

if "requirements" not in recipe:
    recipe["requirements"] = {}

if "run_constraints" not in recipe["requirements"]:
    recipe["requirements"]["run_constraints"] = []

run_constraints = recipe["requirements"]["run_constraints"]
existing_packages = {}
for i, constraint in enumerate(run_constraints):
    if isinstance(constraint, str):
        parts = constraint.split(">=")
        if len(parts) == 2:
            package = parts[0].strip()
            existing_packages[package] = i

for package, min_version in minimum_versions.items():
    constraint_str = f"{package} >={min_version}"
    if package in existing_packages:
        run_constraints[existing_packages[package]] = constraint_str
    else:
        run_constraints.append(constraint_str)

with open("recipe.yaml", "w") as fh:
    yaml.dump(recipe, fh)

print("Successfully updated recipe.yaml")
