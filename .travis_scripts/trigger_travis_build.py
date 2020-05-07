"""
Trigger the conda-forge.github.io Travis job to restart.
"""


import argparse
import os

import requests
import six

import conda_smithy.ci_register


def rebuild_travis(repo_slug):
    headers = conda_smithy.ci_register.travis_headers()

    # If we don't specify the API version, we get a 404.
    # Also fix the accepted content type.
    headers["Accept"] = "application/json"
    headers["Travis-API-Version"] = "3"

    # Trigger a build on `master`.
    encoded_slug = six.moves.urllib.parse.quote(repo_slug, safe='')
    url = 'https://api.travis-ci.com/repo/{}/requests'.format(encoded_slug)
    response = requests.post(
        url,
        json={
            "request": {
                "branch": "master",
                "message": "Triggering build from staged-recipes",
            }
        },
        headers=headers
    )
    if response.status_code != 201:
        print(response.content)
        response.raise_for_status()


def main(argv):
    parser = argparse.ArgumentParser(description="Trigger Travis CI build.")
    parser.add_argument("slug", type=str, help="repo to trigger build for")

    args = parser.parse_args(argv[1:])

    rebuild_travis(args.slug)

    return 0


if __name__ == '__main__':
    import sys
    sys.exit(main(sys.argv))
