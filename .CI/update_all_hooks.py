from __future__ import print_function

import os
import requests

import ruamel.yaml
import subprocess
from github import Github

circle_token = os.environ["CIRCLE_TOKEN"]
appveyor_token = os.environ["APPVEYOR_TOKEN"]
anaconda_token = os.environ["BINSTAR_TOKEN"]
gh_token = os.environ["GH_TOKEN"]

smithy_conf = os.path.expanduser('~/.conda-smithy')
if not os.path.exists(smithy_conf):
    os.mkdir(smithy_conf)

def write_token(name, token):
    with open(os.path.join(smithy_conf, name + '.token'), 'w') as fh:
        fh.write(token)

if 'APPVEYOR_TOKEN' in os.environ:
    write_token('appveyor', os.environ['APPVEYOR_TOKEN'])
if 'CIRCLE_TOKEN' in os.environ:
    write_token('circle', os.environ['CIRCLE_TOKEN'])
if 'GH_TOKEN' in os.environ:
    write_token('github', os.environ['GH_TOKEN'])

from conda_smithy.ci_register import add_conda_forge_webservice_hooks

if __name__ == '__main__':
    owner = 'conda-forge'
    gh = Github(gh_token)
    org = gh.get_organization(owner)
    split_num, no_cases = os.getenv("TEST_SPLIT", "0/1").split("/")
    split_num, no_cases = int(split_num), int(no_cases)
    i = -1
    for feedstock in org.get_repos():
        i = i + 1
        if i % no_cases != split_num:
            continue
        print(i, feedstock.name)
        if not feedstock.name.endswith('-feedstock'):
            continue
        repo = feedstock.name
        add_conda_forge_webservice_hooks(owner, repo)

