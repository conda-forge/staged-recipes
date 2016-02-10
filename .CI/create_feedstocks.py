#!/usr/bin/env python
"""
Convert all recipes into feedstocks.

This script is to be run in a TravisCI context, with all secret environment variables defined (BINSTAR_TOKEN, GH_TOKEN)
Such as:

    export GH_TOKEN=$(cat ~/.conda-smithy/github.token)

"""
from __future__ import print_function

from conda_smithy.github import gh_token
from contextlib import contextmanager
from github import Github, GithubException
import os.path
import shutil
import subprocess
import tempfile


# Enable DEBUG to run the diagnostics, without actually creating new feedstocks.
DEBUG = False


def list_recipes():
    recipe_directory_name = 'ready_recipes'
    if os.path.isdir(recipe_directory_name):
        recipes = os.listdir(recipe_directory_name)
    else:
        recipes = []

    for recipe_dir in recipes:
        # We don't list the "example" feedstock. It is an example, and is there
        # to be helpful.
        if recipe_dir.startswith('example'):
            continue
        path = os.path.abspath(os.path.join(recipe_directory_name, recipe_dir))
        yield path, recipe_dir


@contextmanager
def tmp_dir(*args, **kwargs):
    temp_dir = tempfile.mkdtemp(*args, **kwargs)
    try:
        yield temp_dir 
    finally:
        shutil.rmtree(temp_dir)


def repo_exists(organization, name):
    token = gh_token()
    gh = Github(token)
    # Use the organization provided.
    org = gh.get_organization(organization)
    try:
        gh_repo = org.get_repo(name)
        return True
    except GithubException as e:
        if e.status == 404:
            return False
        raise


if __name__ == '__main__':
    is_merged_pr = (os.environ.get('TRAVIS_BRANCH') == 'master' and os.environ.get('TRAVIS_PULL_REQUEST') == 'false')

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

    print('Calculating the recipes which need to be turned into feedstocks.')
    removed_recipes = []
    with tmp_dir('__feedstocks') as feedstocks_dir:
        for recipe_dir, name in list_recipes():
            feedstock_dir = os.path.join(feedstocks_dir, name + '-feedstock')
            os.mkdir(feedstock_dir)
            print('Making feedstock for {}'.format(name))

            owner_info = ['--organization', 'conda-forge']
            if DEBUG:
                # owner_info = ['--user', 'pelson']
                pass

            subprocess.check_call(['conda', 'smithy', 'recipe-lint', recipe_dir])

            subprocess.check_call(['conda', 'smithy', 'init', recipe_dir,
                                   '--feedstock-directory', feedstock_dir])
            if not is_merged_pr:
                # We just want to check that conda-smithy is doing its thing without having any metadata issues.
                continue

            subprocess.check_call(['git', 'remote', 'add', 'upstream_with_token',
                                   'https://conda-forge-admin:{}@github.com/conda-forge/{}'.format(os.environ['GH_TOKEN'],
                                                                                                   os.path.basename(feedstock_dir))],
                                   cwd=feedstock_dir)


            # Sometimes we already have the feedstock created. We need to deal with that case.
            if repo_exists('conda-forge', os.path.basename(feedstock_dir)):
                subprocess.check_call(['git', 'fetch', 'upstream_with_token'], cwd=feedstock_dir)
                subprocess.check_call(['git', 'branch', '-m', 'master', 'old'], cwd=feedstock_dir)
                try:
                    subprocess.check_call(['git', 'checkout', '-b', 'master', 'upstream_with_token/master'], cwd=feedstock_dir)
                except subprocess.CalledProcessError:
                    # Sometimes, we have a repo, but there are no commits on it! Just catch that case.
                    subprocess.check_call(['git', 'checkout', '-b' 'master'], cwd=feedstock_dir)
            else:
                subprocess.check_call(['conda', 'smithy', 'github-create', feedstock_dir] + owner_info)

            subprocess.check_call(['conda', 'smithy', 'register-feedstock-ci', feedstock_dir] + owner_info)

            subprocess.check_call(['conda', 'smithy', 'rerender'], cwd=feedstock_dir)
            subprocess.check_call(['git', 'commit', '-am', "Re-render the feedstock after CI registration."], cwd=feedstock_dir)
            # Capture the output, as it may contain the GH_TOKEN.
            out = subprocess.check_output(['git', 'push', 'upstream_with_token', 'master'], cwd=feedstock_dir,
                                          stderr=subprocess.STDOUT)

            # Remove this recipe from the repo.
            removed_recipes.append(name)
            if is_merged_pr:
                subprocess.check_call(['git', 'rm', '-r', recipe_dir])

            if len(removed_recipes) >= 2:
                break

    # Commit any removed packages.
    subprocess.check_call(['git', 'status'])
    if removed_recipes:
        subprocess.check_call(['git', 'checkout', os.environ.get('TRAVIS_BRANCH')])
        msg = ('Removed recipe{s} ({}) after converting into feedstock{s}.'
               ''.format(', '.join(removed_recipes),
                         s='s' if len(removed_recipes) > 1 else ''))
        if is_merged_pr:
            subprocess.check_call(['git', 'remote', 'add', 'upstream_with_token',
                                   'https://conda-forge-admin:{}@github.com/conda-forge/staged-recipes'.format(os.environ['GH_TOKEN'])])
            subprocess.check_call(['git', 'commit', '-m', msg])
            # Capture the output, as it may contain the GH_TOKEN.
            out = subprocess.check_output(['git', 'push', 'upstream_with_token', os.environ.get('TRAVIS_BRANCH')],
                                          stderr=subprocess.STDOUT)
        else:
            print('Would git commit, with the following message: \n   {}'.format(msg))

