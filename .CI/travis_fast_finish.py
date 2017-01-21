#!/usr/bin/env python


from future_builtins import map, filter

import os

import requests


def check_latest_pr_build(repo, pr, build_num):
    # Not a PR so it is latest.
    if pr is None:
        return True

    headers = {
        "Accept": "application/vnd.travis-ci.2+json",
    }
    url = "https://api.travis-ci.org/repos/{repo}/builds?event_type=pull_request"

    response = requests.get(url.format(repo=repo), headers=headers)
    if response.status_code != 200:
        response.raise_for_status()

    # Parse the response to get a list of build numbers for this PR.
    builds = response.json()["builds"]
    pr_builds = filter(lambda b: b["pull_request_number"] == pr, builds)
    pr_build_nums = sorted(map(lambda b: int(b["number"]), pr_builds))

    # Check if our build number is the latest (largest)
    # out of all of the builds for this PR.
    if build_num < max(pr_build_nums):
        return False
    else:
        return True


def main():
    repo = os.environ["TRAVIS_REPO_SLUG"]

    pr = os.environ["TRAVIS_PULL_REQUEST"]
    pr = None if pr == "false" else int(pr)

    build_num = os.environ["TRAVIS_BUILD_NUMBER"]

    return int(check_latest_pr_build(repo, pr, build_num) is False)


if __name__ == "__main__":
    import sys
    sys.exit(main())
