"""
Trigger the conda-forge.github.io Travis job to restart.

"""
import requests
import six

import conda_smithy.ci_register
from conda_smithy.github import gh_token


def rebuild_travis(gh_token, repo_slug):
    headers = {
               # If the user-agent isn't defined correctly, we will recieve a 403.
               'User-Agent': 'MyClient/1.0.0',
               'Accept': 'application/vnd.travis-ci.2+json',
               }
    url = 'https://api.travis-ci.org/auth/github'
    data = {"github_token": gh_token}
    response = requests.post(url, json=data, headers=headers)
    if response.status_code != 201:
        response.raise_for_status()
    
    token = response.json()['access_token']
    headers['Authorization'] = 'token {}'.format(token)

    # If we don't specify API the version, we get a 404.
    headers.update({'Travis-API-Version': '3'})
    
    encoded_slug = six.moves.urllib.parse.quote(repo_slug, safe='')
    url = 'https://api.travis-ci.org/repo/{}/requests'.format(encoded_slug)
    response = requests.post(url, json={"request": {"branch": "master"}},
                             headers=headers)
    if response.status_code != 201:
        response.raise_for_status()


if __name__ == '__main__':
    rebuild_travis(gh_token(), 'conda-forge/conda-forge.github.io')
