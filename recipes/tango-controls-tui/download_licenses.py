"""Script to download the license of rust dependencies

The file dependencies.json should be generated using:
cargo-license --json > dependencies.json

Creating a token to authenticate to GitHub is higly recommended
to avoid rate-limiting.
export GH_OAUTH_TOKEN=<mytoken>
python download_licenses.py
"""

import base64
import json
import os
import urllib.parse
import requests
from pathlib import Path
from typing import Optional, Dict

CURRENT_DIR = Path(__file__).parents[0].absolute()
LIBRARY_LICENSES = CURRENT_DIR / "library_licenses"
DEPENDENCIES = "dependencies.json"
GITHUB_REPO_API = "https://api.github.com/repos"
GITLAB_REPO_API = "https://gitlab.com/api/v4/projects"
WHITELIST = {"tango-controls-tui"}
GH_OAUTH_TOKEN = os.getenv("GH_OAUTH_TOKEN")
GH_HEADERS = {"Accept": "application/vnd.github.v3+json"}
if GH_OAUTH_TOKEN is not None:
    # Make authenticated requests to avoid rate limiting
    GH_HEADERS["Authorization"] = f"token {GH_OAUTH_TOKEN}"


def url_encode(s: str) -> str:
    """Return a url encoded string to be used as GitLab project id

    . is also replaced by %2E
    """
    return urllib.parse.quote(s, safe="").replace(".", "%2E")


def get_gitlab_license(repo_url: str) -> str:
    """Return the license from the gitlab repository

    Rust packages are often under dual license.
    Take the first "LICENSE*" file found.
    """
    # Get the gitlab repo encoded url (used as id)
    # https://gitlab.com/CreepySkeleton/proc-macro-error -> CreepySkeleton%2Fproc-macro-error
    repo_id = url_encode(repo_url.replace("https://gitlab.com/", ""))
    response = requests.get(
        f"{GITLAB_REPO_API}/{repo_id}/repository/tree",
    )
    response.raise_for_status()
    for content in response.json():
        if content["name"].startswith("LICENSE"):
            print(f"Downloading {content['name']} from {repo_url}")
            result = requests.get(
                f"{GITLAB_REPO_API}/{repo_id}/repository/blobs/{content['id']}"
            )
            result.raise_for_status()
            return base64.b64decode(result.json()["content"]).decode("utf-8")
    raise FileNotFoundError(f"No license found in {repo_url}")


def get_github_license(repo_url: str) -> str:
    """Return the license from the github repository"""
    # Get the repo owner and name
    # Always look at the root of the repo even when a subdirectory is given
    # (license is usually at the root only)
    # https://github.com/rust-num/num-traits -> rust_num, num-traits
    # https://github.com/clap-rs/clap/tree/master/clap_derive -> clap-rs, clap
    repo_owner, repo_name = repo_url.split("/")[3:5]
    if repo_name.endswith(".git"):
        repo_name = repo_name.replace(".git", "")
    response = requests.get(
        f"{GITHUB_REPO_API}/{repo_owner}/{repo_name}/license", headers=GH_HEADERS
    )
    response.raise_for_status()
    result = response.json()
    print(f"Downloading {result['name']} from {repo_url}")
    return base64.b64decode(result["content"]).decode("utf-8")


def get_license_from_repo(repo_url: str) -> str:
    """Get the license from the repository"""
    if repo_url.startswith("https://github.com/"):
        license_text = get_github_license(repo_url)
    elif repo_url.startswith("https://gitlab.com/"):
        license_text = get_gitlab_license(repo_url)
    else:
        raise ValueError(f"WARNING! Unsupported repo url: {repo_url}")
    return license_text


def get_template_license(license: str):
    # GPL-3.0+ -> gpl-3.0
    license = license.lower().replace("+", "")
    response = requests.get(
        f"https://api.github.com/licenses/{license}", headers=GH_HEADERS
    )
    response.raise_for_status()
    print(f"Downloading {license} template")
    return response.json()["body"]


def get_license(pkg: Dict[str, Optional[str]]):
    repo_url = pkg["repository"]
    pkg_license = pkg["license"].split()[0]
    if repo_url is None:
        print(f"WARNING! No repository provided for {pkg['name']}")
        return get_template_license(pkg_license)
    try:
        return get_license_from_repo(repo_url)
    except Exception as e:
        print(e)
        return get_template_license(pkg_license)


def main():
    deps = json.load(open(DEPENDENCIES, "r"))
    for pkg in deps:
        pkg_name = pkg["name"]
        if pkg_name in WHITELIST:
            continue
        print(f"Checking {pkg_name}...")
        license_file = LIBRARY_LICENSES / f"{pkg_name}-{pkg['version']}-license"
        if license_file.exists():
            # No need to re-download existing licenses
            # Allow to re-run the script several times
            continue
        try:
            license_text = get_license(pkg)
        except Exception as e:
            print(e)
        else:
            print(f"Creating {license_file}")
            license_file.write_text(license_text)


if __name__ == "__main__":
    main()
