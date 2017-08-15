#!/usr/bin/env python

"""
Fast finish old PR builds on CIs

Using various CI's (CircleCI, Travis CI, and AppVeyor) APIs and information
about the current build for the relevant CI, this script checks to see if the
current PR build is the most recent one. It does this by comparing the current
PR build's build number to other build numbers of builds for this PR. If it is
not the most recent build for the PR, then this script exits with a failure.
Thus it can fail the build; stopping it from proceeding further. However, if
it is the most recent build number or if it is not a PR (e.g. a build on a
normal branch), then the build proceeds without issues.
"""


try:
    from future_builtins import (
        map,
        filter,
    )
except ImportError:
    pass

import argparse
import codecs
import contextlib
import json
import os
import sys

try:
    from urllib.request import (
        Request,
        urlopen,
    )
except ImportError:
    from urllib2 import (
        Request,
        urlopen,
    )


def request_json(url, headers={}):
    request = Request(url, headers=headers)
    with contextlib.closing(urlopen(request)) as response:
        reader = codecs.getreader("utf-8")
        return json.load(reader(response))


def circle_check_latest_pr_build(repo, pr, build_num):
    # Not a PR so it is latest.
    if pr is None:
        return True

    headers = {
        "Accept": "application/json",
    }
    url = "https://circleci.com/api/v1.1/project/github/{repo}/tree/pull/{pr}"

    builds = request_json(url.format(repo=repo, pr=pr), headers=headers)

    # Parse the response to get a list of build numbers for this PR.
    job_name = os.environ.get("CIRCLE_JOB")
    same_param_builds = []
    for b in builds:
        b_params = b.get("build_parameters") or {}
        if b_params.get("CIRCLE_JOB") == job_name:
            same_param_builds.append(b)
    pr_build_nums = set(map(lambda b: int(b["build_num"]), same_param_builds))
    pr_build_nums.add(build_num)

    # Check if our build number is the latest (largest)
    # out of all of the builds for this PR.
    if build_num < max(pr_build_nums):
        return False
    else:
        return True


def travis_check_latest_pr_build(repo, pr, build_num):
    # Not a PR so it is latest.
    if pr is None:
        return True

    headers = {
        "Accept": "application/vnd.travis-ci.2+json",
    }
    url = "https://api.travis-ci.org/repos/{repo}/builds?event_type=pull_request"

    data = request_json(url.format(repo=repo), headers=headers)

    # Parse the response to get a list of build numbers for this PR.
    builds = data["builds"]
    pr_builds = filter(lambda b: b["pull_request_number"] == pr, builds)
    pr_build_nums = set(map(lambda b: int(b["number"]), pr_builds))
    pr_build_nums.add(build_num)

    # Check if our build number is the latest (largest)
    # out of all of the builds for this PR.
    if build_num < max(pr_build_nums):
        return False
    else:
        return True


def appveyor_check_latest_pr_build(repo, pr, build_num, total_builds=50):
    # Not a PR so it is latest.
    if pr is None:
        return True

    headers = {
        "Accept": "application/json",
    }
    url = "https://ci.appveyor.com/api/projects/{repo}/history?recordsNumber={total_builds}"

    data = request_json(url.format(repo=repo, total_builds=total_builds), headers=headers)

    # Parse the response to get a list of build numbers for this PR.
    builds = data["builds"]
    pr_builds = filter(lambda b: b.get("pullRequestId", "") == str(pr), builds)
    pr_build_nums = set(map(lambda b: int(b["buildNumber"]), pr_builds))
    pr_build_nums.add(build_num)

    # Check if our build number is the latest (largest)
    # out of all of the builds for this PR.
    if build_num < max(pr_build_nums):
        return False
    else:
        return True


def main(*args):
    if not args:
        args = sys.argv[1:]

    parser = argparse.ArgumentParser(
        description=__doc__.strip().splitlines()[0]
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Whether to include output",
    )
    parser.add_argument(
        "--ci",
        required=True,
        choices=[
            "circle",
            "travis",
            "appveyor",
        ],
        help="Which CI to check for an outdated build",
    )
    parser.add_argument(
        "repo",
        type=str,
        help="GitHub repo name (e.g. `user/repo`.)",
    )
    parser.add_argument(
        "bld",
        type=int,
        help="CI build number for this pull request",
    )
    parser.add_argument(
        "pr",
        nargs="?",
        default="",
        help="GitHub pull request number of this build",
    )

    params = parser.parse_args(args)
    verbose = params.verbose
    ci = params.ci
    repo = params.repo
    bld = params.bld
    try:
        pr = int(params.pr)
    except ValueError:
        pr = None

    if verbose:
        print("Checking to see if this PR build is outdated.")

    exit_code = 0
    if ci == "circle":
        exit_code = int(circle_check_latest_pr_build(repo, pr, bld) is False)
    elif ci == "travis":
        exit_code = int(travis_check_latest_pr_build(repo, pr, bld) is False)
    elif ci == "appveyor":
        exit_code = int(appveyor_check_latest_pr_build(repo, pr, bld) is False)

    if verbose and exit_code == 1:
        print("Failing outdated PR build to end it.")

    return exit_code


if __name__ == "__main__":
    sys.exit(main())
