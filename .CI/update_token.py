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

from conda_smithy.ci_register import (add_token_to_circle, travis_headers,
    travis_encrypt_binstar_token, appveyor_encrypt_binstar_token,
    travis_token_update_conda_forge_config)

def read_conda_forge_yml():
    forge_yaml = os.path.join(feedstock_directory, 'conda-forge.yml')
    if os.path.exists(forge_yaml):
        with open(forge_yaml, 'r') as fh:
            forge_code = ruamel.yaml.load(fh, ruamel.yaml.RoundTripLoader)
    else:
        forge_code = {}
    # Code could come in as an empty list.
    if not forge_code:
        forge_code = {}
    return forge_code


def update_travis_yml(forge_code):
    token = forge_code['travis']['secure']['BINSTAR_TOKEN']
    travis_yml = os.path.join(feedstock_directory, '.travis.yml')
    if not os.path.exists(travis_yml):
        return
    with open(travis_yml, 'r') as fh:
        lines = [line for line in fh]
    with open(travis_yml, 'w') as fh:
        for line in lines:
            if line.lstrip().startswith('- secure'):
                line = line.split(':')[0] + ': "' + token + '"\n'
            fh.write(line)
    subprocess.check_output(["git", "add", ".travis.yml"])


def update_appveyor_yml(forge_code):
    token = forge_code['appveyor']['secure']['BINSTAR_TOKEN']
    appveyor_yml = os.path.join(feedstock_directory, 'appveyor.yml')
    if not os.path.exists(appveyor_yml):
        return
    with open(appveyor_yml, 'r') as fh:
        lines = [line for line in fh]
    with open(appveyor_yml, 'w') as fh:
        for line in lines:
            if line.lstrip().startswith('secure:'):
                line = line.split(':')[0] + ': ' + token + '\n'
            fh.write(line)
    subprocess.check_output(["git", "add", "appveyor.yml"])


if __name__ == '__main__':
    expected_appveyor_token = "ipv/06DzgA7pzz2CIAtbPxZSsphDtF+JFyoWRnXkn3O8j7oRe3rzqj3LOoq2DZp4"
    owner = 'conda-forge'
    gh = Github(gh_token)
    org = gh.get_organization(owner)
    cwd = os.getcwd()
    for feedstock in org.get_repos():
        print(feedstock.name)
        if not feedstock.name.endswith('-feedstock'):
            continue
        repo = feedstock.name
        os.chdir(cwd)
        try:
            subprocess.check_output(["git", "clone", "https://{}@github.com/{}/{}".format(gh_token, owner, repo)])
            os.chdir(repo)
            feedstock_directory = os.getcwd()
            forge_code = read_conda_forge_yml()
            if (forge_code['appveyor']['secure']['BINSTAR_TOKEN'] != expected_appveyor_token):
                print('Updating {}/{}:'.format(owner, repo))

                travis_token_update_conda_forge_config(feedstock_directory, owner, repo)
                add_token_to_circle(owner, repo)
                appveyor_encrypt_binstar_token(feedstock_directory, owner, repo)

                forge_code = read_conda_forge_yml()
                update_travis_yml(forge_code)
                update_appveyor_yml(forge_code)

                subprocess.check_output(["git", "add", "conda-forge.yml"])
                subprocess.check_output(["git", "commit", "-m", "[ci skip] [skip ci] Update anaconda token"])
                subprocess.check_output(["git", "push", "origin", "master"])

                print("Done")
            else:
                print('{}/{} is already updated'.format(owner, repo))
        except subprocess.CalledProcessError as e:
            print('{}/{} updating failed'.format(owner, repo))
        except KeyError as e:
            print('{}/{} updating failed with KeyError'.format(owner, repo))
