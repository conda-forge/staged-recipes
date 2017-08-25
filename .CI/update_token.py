from __future__ import print_function

import os
import requests

import ruamel.yaml
import subprocess

circle_token = os.environ["CIRCLE_TOKEN"]
appveyor_token = os.environ["APPVEYOR_TOKEN"]
anaconda_token = os.environ["BINSTAR_TOKEN"]
gh_token = os.environ["GH_TOKEN"]


def add_token_to_circle(user, project):
    url_template = ('https://circleci.com/api/v1.1/project/github/{user}/{project}/envvar?'
                    'circle-token={token}')
    url = url_template.format(token=circle_token, user=user, project=project)
    data = {'name': 'BINSTAR_TOKEN', 'value': anaconda_token}
    response = requests.post(url, data)
    if response.status_code != 201:
        raise ValueError(response)


def appveyor_encrypt_binstar_token(feedstock_directory, user, project):
    headers = {'Authorization': 'Bearer {}'.format(appveyor_token)}
    url = 'https://ci.appveyor.com/api/account/encrypt'
    response = requests.post(url, headers=headers, data={"plainValue": anaconda_token})
    if response.status_code != 200:
        raise ValueError(response)

    forge_yaml = os.path.join(feedstock_directory, 'conda-forge.yml')
    if os.path.exists(forge_yaml):
        with open(forge_yaml, 'r') as fh:
            code = ruamel.yaml.load(fh, ruamel.yaml.RoundTripLoader)
    else:
        code = {}

    # Code could come in as an empty list.
    if not code:
        code = {}

    code.setdefault('appveyor', {}).setdefault('secure', {})['BINSTAR_TOKEN'] = response.content.decode('utf-8')
    with open(forge_yaml, 'w') as fh:
        fh.write(ruamel.yaml.dump(code, Dumper=ruamel.yaml.RoundTripDumper))


def travis_token_update_conda_forge_config(feedstock_directory, user, project):
    item = 'BINSTAR_TOKEN="{}"'.format(anaconda_token)
    slug = "{}/{}".format(user, project)

    forge_yaml = os.path.join(feedstock_directory, 'conda-forge.yml')
    if os.path.exists(forge_yaml):
        with open(forge_yaml, 'r') as fh:
            code = ruamel.yaml.load(fh, ruamel.yaml.RoundTripLoader)
    else:
        code = {}

    # Code could come in as an empty list.
    if not code:
        code = {}

    code.setdefault('travis', {}).setdefault('secure', {})['BINSTAR_TOKEN'] = (
        travis_encrypt_binstar_token(slug, item)
    )
    with open(forge_yaml, 'w') as fh:
        fh.write(ruamel.yaml.dump(code, Dumper=ruamel.yaml.RoundTripDumper))


def travis_encrypt_binstar_token(repo, string_to_encrypt):
    # Copyright 2014 Matt Martz <matt@sivel.net>
    # All Rights Reserved.
    #
    #    Licensed under the Apache License, Version 2.0 (the "License"); you may
    #    not use this file except in compliance with the License. You may obtain
    #    a copy of the License at
    #
    #         http://www.apache.org/licenses/LICENSE-2.0
    #
    #    Unless required by applicable law or agreed to in writing, software
    #    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
    #    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
    #    License for the specific language governing permissions and limitations
    #    under the License.
    from Crypto.PublicKey import RSA
    from Crypto.Cipher import PKCS1_v1_5
    import base64

    keyurl = 'https://api.travis-ci.org/repos/{0}/key'.format(repo)
    r = requests.get(keyurl, headers=travis_headers())
    r.raise_for_status()
    public_key = r.json()['key']
    key = RSA.importKey(public_key)
    cipher = PKCS1_v1_5.new(key)
    return base64.b64encode(cipher.encrypt(string_to_encrypt.encode())).decode('utf-8')


def travis_headers():
    headers = {
               # If the user-agent isn't defined correctly, we will recieve a 403.
               'User-Agent': 'Travis/1.0',
               'Accept': 'application/vnd.travis-ci.2+json',
               'Content-Type': 'application/json'
               }
    endpoint = 'https://api.travis-ci.org'
    url = '{}/auth/github'.format(endpoint)
    data = {"github_token": gh_token}
    travis_token = os.path.expanduser('~/.conda-smithy/travis.token')
    if not os.path.exists(travis_token):
        response = requests.post(url, json=data, headers=headers)
        if response.status_code != 201:
            response.raise_for_status()
        token = response.json()['access_token']
        with open(travis_token, 'w') as fh:
            fh.write(token)
        # TODO: Set the permissions on the file.
    else:
        with open(travis_token, 'r') as fh:
            token = fh.read().strip()

    headers['Authorization'] = 'token {}'.format(token)
    return headers


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
                line = line.split(':')[0] + ': "' + token + '"'
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
                line = line.split(':')[0] + ': ' + token
            fh.write(line)
    subprocess.check_output(["git", "add", "appveyor.yml"])


if __name__ == '__main__':
    expected_appveyor_token = "ipv/06DzgA7pzz2CIAtbPxZSsphDtF+JFyoWRnXkn3O8j7oRe3rzqj3LOoq2DZp4"
    smithy_conf = os.path.expanduser('~/.conda-smithy')
    if not os.path.exists(smithy_conf):
        os.mkdir(smithy_conf)

    feedstock_directory = os.getcwd()
    owner = 'conda-forge'
    repo = os.path.basename(os.path.abspath(feedstock_directory))
    try:
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
    except RuntimeError as e:
        print(e)
