"""
Trigger the staged-recipes Travis job to restart.
"""


import os

import requests
import six

import conda_smithy.ci_register


def rebuild_travis(repo_slug):
    headers = conda_smithy.ci_register.travis_headers()

    # If we don't specify the API version, we get a 404.
    headers.update({'Travis-API-Version': '3'})

    # Trigger a build on `master`.
    encoded_slug = six.moves.urllib.parse.quote(repo_slug, safe='')
    url = 'https://api.travis-ci.org/repo/{}/requests'.format(encoded_slug)
    response = requests.post(
        url,
        json={"request": {"branch": "master"}},
        headers=headers
    )
    if response.status_code != 201:
        response.raise_for_status()


if __name__ == '__main__':
    rebuild_travis('conda-forge/staged-recipes')
