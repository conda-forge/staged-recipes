#!/usr/bin/env python
"""
Convert all recipes into feedstocks.

This script is to be run in a TravisCI context, with all secret environment
variables defined (BINSTAR_TOKEN, GH_TOKEN)

Such as:

    export GH_TOKEN=$(cat ~/.conda-smithy/github.token)

"""
from __future__ import print_function

from conda_build.metadata import MetaData
from conda_smithy.utils import get_feedstock_name_from_meta
from contextlib import contextmanager
from datetime import datetime
from github import Github, GithubException
import os.path
import shutil
import subprocess
import sys
import tempfile
import traceback
import time

import requests
from ruamel.yaml import YAML

# Enable DEBUG to run the diagnostics, without actually creating new feedstocks.
DEBUG = False

REPO_SKIP_LIST = ["core", "bot", "staged-recipes", "arm-arch", "systems"]

recipe_directory_name = 'recipes'


def list_recipes():
    if os.path.isdir(recipe_directory_name):
        recipes = os.listdir(recipe_directory_name)
    else:
        recipes = []

    for recipe_dir in recipes:
        # We don't list the "example" feedstock. It is an example, and is there
        # to be helpful.
        # .DS_Store is created by macOS to store custom attributes of its
        # containing folder.
        if recipe_dir in ['example', '.DS_Store']:
            continue
        path = os.path.abspath(os.path.join(recipe_directory_name, recipe_dir))
        yield path, get_feedstock_name_from_meta(MetaData(path))


@contextmanager
def tmp_dir(*args, **kwargs):
    temp_dir = tempfile.mkdtemp(*args, **kwargs)
    try:
        yield temp_dir
    finally:
        shutil.rmtree(temp_dir)


def repo_exists(gh, organization, name):
    # Use the organization provided.
    org = gh.get_organization(organization)
    try:
        org.get_repo(name)
        return True
    except GithubException as e:
        if e.status == 404:
            return False
        raise


def feedstock_token_exists(organization, name):
    r = requests.get(
        "https://api.github.com/repos/%s/"
        "feedstock-tokens/contents/tokens/%s.json" % (organization, name),
        headers={"Authorization": "token %s" % os.environ["GH_TOKEN"]},
    )
    if r.status_code != 200:
        return False
    else:
        return True


def print_rate_limiting_info(gh, user):
    # Compute some info about our GitHub API Rate Limit.
    # Note that it doesn't count against our limit to
    # get this info. So, we should be doing this regularly
    # to better know when it is going to run out. Also,
    # this will help us better understand where we are
    # spending it and how to better optimize it.

    # Get GitHub API Rate Limit usage and total
    gh_api_remaining = gh.get_rate_limit().core.remaining
    gh_api_total = gh.get_rate_limit().core.limit

    # Compute time until GitHub API Rate Limit reset
    gh_api_reset_time = gh.get_rate_limit().core.reset
    gh_api_reset_time -= datetime.utcnow()

    print("")
    print("GitHub API Rate Limit Info:")
    print("---------------------------")
    print("token: ", user)
    print("Currently remaining {remaining} out of {total}.".format(
        remaining=gh_api_remaining, total=gh_api_total))
    print("Will reset in {time}.".format(time=gh_api_reset_time))
    print("")
    return gh_api_remaining


def sleep_until_reset(gh):
    # sleep the job with printing every minute if we are out
    # of github api requests

    gh_api_remaining = gh.get_rate_limit().core.remaining

    if gh_api_remaining == 0:
        # Compute time until GitHub API Rate Limit reset
        gh_api_reset_time = gh.get_rate_limit().core.reset
        gh_api_reset_time -= datetime.utcnow()

        mins_to_sleep = int(gh_api_reset_time.total_seconds() / 60)
        mins_to_sleep += 2

        print("Sleeping until GitHub API resets.")
        for i in range(mins_to_sleep):
            time.sleep(60)
            print("slept for minute {curr} out of {tot}.".format(
                curr=i+1, tot=mins_to_sleep))
        return True
    else:
        return False


if __name__ == '__main__':
    exit_code = 0

    is_merged_pr = os.environ.get('CF_CURRENT_BRANCH') == 'master'

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
    if 'AZURE_TOKEN' in os.environ:
        write_token('azure', os.environ['AZURE_TOKEN'])
    if 'DRONE_TOKEN' in os.environ:
        write_token('drone', os.environ['DRONE_TOKEN'])

    gh_drone = Github(os.environ['GH_DRONE_TOKEN'])
    gh_drone_remaining = print_rate_limiting_info(gh_drone, 'GH_DRONE_TOKEN')

    gh = None
    if 'GH_TOKEN' in os.environ:
        write_token('github', os.environ['GH_TOKEN'])
        gh = Github(os.environ['GH_TOKEN'])

        # Get our initial rate limit info.
        gh_remaining = print_rate_limiting_info(gh, 'GH_TOKEN')

        # if we are out, exit early
        # if sleep_until_reset(gh):
        #     sys.exit(1)

        # try the other token maybe?
        # if gh_remaining < gh_drone_remaining and gh_remaining < 100:
        #     write_token('github', os.environ['GH_DRONE_TOKEN'])
        #     gh = Github(os.environ['GH_DRONE_TOKEN'])

    owner_info = ['--organization', 'conda-forge']

    print('Calculating the recipes which need to be turned into feedstocks.')
    with tmp_dir('__feedstocks') as feedstocks_dir:
        feedstock_dirs = []
        for recipe_dir, name in list_recipes():
            if name.lower() in REPO_SKIP_LIST:
                continue
            feedstock_dir = os.path.join(feedstocks_dir, name + '-feedstock')
            print('Making feedstock for {}'.format(name))
            try:
                subprocess.check_call(
                    ['conda', 'smithy', 'init', recipe_dir,
                     '--feedstock-directory', feedstock_dir])
            except subprocess.CalledProcessError:
                traceback.print_exception(*sys.exc_info())
                continue

            if not is_merged_pr:
                # We just want to check that conda-smithy is doing its
                # thing without having any metadata issues.
                continue

            feedstock_dirs.append([feedstock_dir, name, recipe_dir])

            subprocess.check_call([
                'git', 'remote', 'add', 'upstream_with_token',
                'https://conda-forge-manager:{}@github.com/'
                'conda-forge/{}-feedstock'.format(
                        os.environ['GH_TOKEN'],
                        name
                    )
                ],
                cwd=feedstock_dir
            )
            print_rate_limiting_info(gh_drone, 'GH_DRONE_TOKEN')
            # Sometimes we already have the feedstock created. We need to
            # deal with that case.
            if repo_exists(gh, 'conda-forge', name + '-feedstock'):
                subprocess.check_call(
                    ['git', 'fetch', 'upstream_with_token'], cwd=feedstock_dir)
                subprocess.check_call(
                    ['git', 'branch', '-m', 'master', 'old'], cwd=feedstock_dir)
                try:
                    subprocess.check_call(
                        [
                            'git', 'checkout', '-b', 'master',
                            'upstream_with_token/master'
                        ],
                        cwd=feedstock_dir)
                except subprocess.CalledProcessError:
                    # Sometimes, we have a repo, but there are no commits on
                    # it! Just catch that case.
                    subprocess.check_call(
                        ['git', 'checkout', '-b' 'master'], cwd=feedstock_dir)
            print_rate_limiting_info(gh_drone, 'GH_DRONE_TOKEN')
            subprocess.check_call(
                ['conda', 'smithy', 'register-github', feedstock_dir] + owner_info)
            print_rate_limiting_info(gh_drone, 'GH_DRONE_TOKEN')

        from conda_smithy.ci_register import drone_sync
        print("Running drone sync (can take ~100s)")
        print_rate_limiting_info(gh_drone, 'GH_DRONE_TOKEN')
        drone_sync()
        time.sleep(100)  # actually wait
        print_rate_limiting_info(gh_drone, 'GH_DRONE_TOKEN')

        # Break the previous loop to allow the TravisCI registering
        # to take place only once per function call.
        # Without this, intermittent failures to synch the TravisCI repos ensue.
        # Hang on to any CI registration errors that occur and raise them at the end.
        for num, (feedstock_dir, name, recipe_dir) in enumerate(feedstock_dirs):
            if name.lower() in REPO_SKIP_LIST:
                continue
            print("\n\nregistering CI services for %s..." % name)
            if num >= 10:
                exit_code = 0
                break
            # Try to register each feedstock with CI.
            # However sometimes their APIs have issues for whatever reason.
            # In order to bank our progress, we note the error and handle it.
            # After going through all the recipes and removing the converted ones,
            # we fail the build so that people are aware that things did not clear.
            try:
                write_token('anaconda', os.environ['STAGING_BINSTAR_TOKEN'])
                subprocess.check_call(
                    ['conda', 'smithy', 'register-ci', '--without-appveyor',
                     '--without-webservice', '--feedstock_directory',
                     feedstock_dir] + owner_info)
                subprocess.check_call(
                    ['conda', 'smithy', 'rerender'], cwd=feedstock_dir)
            except subprocess.CalledProcessError:
                exit_code = 0
                traceback.print_exception(*sys.exc_info())
                continue

            # slow down so we make sure we are registered
            for i in range(1, 13):
                time.sleep(10)
                print("Waiting for registration: {i} s".format(i=i*10))

            # if we get here, now we make the feedstock token and add the staging token
            print("making the feedstock token and adding the staging binstar token")
            try:
                if not feedstock_token_exists("conda-forge", name + "-feedstock"):
                    subprocess.check_call(
                        ['conda', 'smithy', 'generate-feedstock-token',
                         '--feedstock_directory', feedstock_dir] + owner_info)
                    subprocess.check_call(
                        ['conda', 'smithy', 'register-feedstock-token',
                         '--feedstock_directory', feedstock_dir] + owner_info)

                write_token('anaconda', os.environ['STAGING_BINSTAR_TOKEN'])
                subprocess.check_call(
                    ['conda', 'smithy', 'rotate-binstar-token',
                     '--without-appveyor',
                     '--token_name', 'STAGING_BINSTAR_TOKEN'],
                    cwd=feedstock_dir)

                yaml = YAML()
                with open(os.path.join(feedstock_dir, "conda-forge.yml"), "r") as fp:
                    _cfg = yaml.load(fp.read())
                _cfg["conda_forge_output_validation"] = True
                with open(os.path.join(feedstock_dir, "conda-forge.yml"), "w") as fp:
                    yaml.dump(_cfg, fp)
                subprocess.check_call(
                    ["git", "add", "conda-forge.yml"],
                    cwd=feedstock_dir
                )
                subprocess.check_call(
                    ['conda', 'smithy', 'rerender'], cwd=feedstock_dir)
            except subprocess.CalledProcessError:
                exit_code = 0
                traceback.print_exception(*sys.exc_info())
                continue

            print("making a commit and pushing...")
            subprocess.check_call(
                ['git', 'commit', '--allow-empty', '-am',
                 "Re-render the feedstock after CI registration."], cwd=feedstock_dir)
            for i in range(5):
                try:
                    # Capture the output, as it may contain the GH_TOKEN.
                    out = subprocess.check_output(
                        ['git', 'push', 'upstream_with_token', 'HEAD:master'],
                        cwd=feedstock_dir,
                        stderr=subprocess.STDOUT)
                    break
                except subprocess.CalledProcessError:
                    pass

                # Likely another job has already pushed to this repo.
                # Place our changes on top of theirs and try again.
                out = subprocess.check_output(
                    ['git', 'fetch', 'upstream_with_token', 'master'],
                    cwd=feedstock_dir,
                    stderr=subprocess.STDOUT)
                try:
                    subprocess.check_call(
                        ['git', 'rebase', 'upstream_with_token/master', 'master'],
                        cwd=feedstock_dir)
                except subprocess.CalledProcessError:
                    # Handle rebase failure by choosing the changes in `master`.
                    subprocess.check_call(
                        ['git', 'checkout', 'master', '--', '.'],
                        cwd=feedstock_dir)
                    subprocess.check_call(
                        ['git', 'rebase', '--continue'], cwd=feedstock_dir)

            # Remove this recipe from the repo.
            if is_merged_pr:
                subprocess.check_call(['git', 'rm', '-rf', recipe_dir])

    # Update status based on the remote.
    subprocess.check_call(['git', 'stash', '--keep-index', '--include-untracked'])
    subprocess.check_call(['git', 'fetch'])
    # CBURR: Debugging
    subprocess.check_call(['git', 'status'])
    subprocess.check_call(['git', 'rebase', '--autostash'])
    subprocess.check_call(['git', 'add', '.'])
    try:
        subprocess.check_call(['git', 'stash', 'pop'])
    except subprocess.CalledProcessError:
        # In case there was nothing to stash.
        # Finish quietly.
        pass

    # Parse `git status --porcelain` to handle some merge conflicts and
    # generate the removed recipe list.
    changed_files = subprocess.check_output(
        ['git', 'status', '--porcelain', recipe_directory_name],
        universal_newlines=True)
    changed_files = changed_files.splitlines()

    # Add all files from AU conflicts. They are new files that we
    # weren't tracking previously.
    # Adding them resolves the conflict and doesn't actually add anything to the index.
    new_file_conflicts = filter(lambda _: _.startswith("AU "), changed_files)
    new_file_conflicts = map(
        lambda _: _.replace("AU", "", 1).lstrip(), new_file_conflicts)
    for each_new_file in new_file_conflicts:
        subprocess.check_call(['git', 'add', each_new_file])

    # Generate a fresh listing of recipes removed.
    #
    # * Each line we get back is a change to a file in the recipe directory.
    # * We narrow the list down to recipes that are staged for deletion
    #   (ignores examples).
    # * Then we clean up the list so that it only has the recipe names.
    removed_recipes = filter(lambda _: _.startswith("D "), changed_files)
    removed_recipes = map(lambda _: _.replace("D", "", 1).lstrip(), removed_recipes)
    removed_recipes = map(
        lambda _: os.path.relpath(_, recipe_directory_name), removed_recipes)
    removed_recipes = map(lambda _: _.split(os.path.sep)[0], removed_recipes)
    removed_recipes = sorted(set(removed_recipes))

    # Commit any removed packages.
    subprocess.check_call(['git', 'status'])
    if removed_recipes:
        msg = ('Removed recipe{s} ({}) after converting into feedstock{s}.'
               ''.format(', '.join(removed_recipes),
                         s=('s' if len(removed_recipes) > 1 else '')))
        msg += ' [ci skip]'
        if is_merged_pr:
            # Capture the output, as it may contain the GH_TOKEN.
            out = subprocess.check_output(
                ['git', 'remote', 'add', 'upstream_with_token',
                 'https://conda-forge-manager:{}@github.com/'
                 'conda-forge/staged-recipes'.format(os.environ['GH_TOKEN'])],
                stderr=subprocess.STDOUT)
            subprocess.check_call(['git', 'commit', '-m', msg])
            # Capture the output, as it may contain the GH_TOKEN.
            branch = os.environ.get('CF_CURRENT_BRANCH')
            out = subprocess.check_output(
                ['git', 'push', 'upstream_with_token', 'HEAD:%s' % branch],
                stderr=subprocess.STDOUT)
        else:
            print('Would git commit, with the following message: \n   {}'.format(msg))

    if gh:
        # Get our final rate limit info.
        print_rate_limiting_info(gh, 'GH_TOKEN')
    if gh_drone:
        print_rate_limiting_info(gh_drone, 'GH_DRONE_TOKEN')

    sys.exit(exit_code)
