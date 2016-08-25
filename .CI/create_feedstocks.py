#!/usr/bin/env python
"""
Convert all recipes into feedstocks.

This script is to be run in a TravisCI context, with all secret environment variables defined (BINSTAR_TOKEN, GH_TOKEN)
Such as:

    export GH_TOKEN=$(cat ~/.conda-smithy/github.token)

"""
from __future__ import print_function

from conda_build.metadata import MetaData
from conda_smithy.github import gh_token
from contextlib import contextmanager
from datetime import datetime
from github import Github, GithubException, Team
import os.path
from random import choice
import shutil
import subprocess
import tempfile


# Enable DEBUG to run the diagnostics, without actually creating new feedstocks.
DEBUG = False


superlative = ['awesome', 'slick', 'formidable', 'awe-inspiring', 'breathtaking',
               'magnificent', 'wonderous', 'stunning', 'astonishing', 'superb',
               'splendid', 'impressive', 'unbeatable', 'excellent', 'top', 'outstanding',
               'exalted', 'standout', 'smashing']


def list_recipes():
    recipe_directory_name = 'recipes'
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
        org.get_repo(name)
        return True
    except GithubException as e:
        if e.status == 404:
            return False
        raise


def create_team(org, name, description, repo_names):
    # PyGithub creates secret teams, and has no way of turning that off! :(
    post_parameters = {
        "name": name,
        "description": description,
        "privacy": "closed",
        "permission": "push",
        "repo_names": repo_names
    }
    headers, data = org._requester.requestJsonAndCheck(
        "POST",
        org.url + "/teams",
        input=post_parameters
    )
    return Team.Team(org._requester, headers, data, completed=True)

def print_rate_limiting_info(gh):
    # Compute some info about our GitHub API Rate Limit.
    # Note that it doesn't count against our limit to
    # get this info. So, we should be doing this regularly
    # to better know when it is going to run out. Also,
    # this will help us better understand where we are
    # spending it and how to better optimize it.

    # Get GitHub API Rate Limit usage and total
    gh_api_remaining, gh_api_total = gh.rate_limiting

    # Compute time until GitHub API Rate Limit reset
    gh_api_reset_time = gh.rate_limiting_resettime
    gh_api_reset_time = datetime.utcfromtimestamp(gh_api_reset_time)
    gh_api_reset_time -= datetime.utcnow()

    print("")
    print("GitHub API Rate Limit Info:")
    print("---------------------------")
    print("Currently remaining {remaining} out of {total}.".format(remaining=gh_api_remaining, total=gh_api_total))
    print("Will reset in {time}.".format(time=gh_api_reset_time))
    print("")



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
    gh = None
    if 'GH_TOKEN' in os.environ:
        write_token('github', os.environ['GH_TOKEN'])
        gh = Github(os.environ['GH_TOKEN'])

        # Get our initial rate limit info.
        print_rate_limiting_info(gh)


    owner_info = ['--organization', 'conda-forge']

    print('Calculating the recipes which need to be turned into feedstocks.')
    removed_recipes = []
    with tmp_dir('__feedstocks') as feedstocks_dir:
        feedstock_dirs = []
        for recipe_dir, name in list_recipes():
            feedstock_dir = os.path.join(feedstocks_dir, name + '-feedstock')
            os.mkdir(feedstock_dir)
            print('Making feedstock for {}'.format(name))

            subprocess.check_call(['conda', 'smithy', 'init', recipe_dir,
                                   '--feedstock-directory', feedstock_dir])
            if not is_merged_pr:
                # We just want to check that conda-smithy is doing its thing without having any metadata issues.
                continue

            feedstock_dirs.append([feedstock_dir, name, recipe_dir])

            subprocess.check_call(['git', 'remote', 'add', 'upstream_with_token',
                                   'https://conda-forge-manager:{}@github.com/conda-forge/{}'.format(os.environ['GH_TOKEN'],
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
                subprocess.check_call(['conda', 'smithy', 'register-github', feedstock_dir] + owner_info)

        conda_forge = None
        teams = None
        if gh:
            # Only get the org and teams if there is stuff to add.
            if feedstock_dirs:
                conda_forge = gh.get_organization('conda-forge')
                teams = {team.name: team for team in conda_forge.get_teams()}

        # Break the previous loop to allow the TravisCI registering to take place only once per function call.
        # Without this, intermittent failiures to synch the TravisCI repos ensue.
        all_maintainers = set()
        for feedstock_dir, name, recipe_dir in feedstock_dirs:
            subprocess.check_call(['conda', 'smithy', 'register-ci', '--feedstock_directory', feedstock_dir] + owner_info)

            subprocess.check_call(['conda', 'smithy', 'rerender'], cwd=feedstock_dir)
            subprocess.check_call(['git', 'commit', '-am', "Re-render the feedstock after CI registration."], cwd=feedstock_dir)
            # Capture the output, as it may contain the GH_TOKEN.
            out = subprocess.check_output(['git', 'push', 'upstream_with_token', 'master'], cwd=feedstock_dir,
                                          stderr=subprocess.STDOUT)

            # Add team members as maintainers.
            if conda_forge:
                meta = MetaData(recipe_dir)
                maintainers = set(meta.meta.get('extra', {}).get('recipe-maintainers', []))
                all_maintainers.update(maintainers)
                team_name = name.lower()
                repo_name = 'conda-forge/{}'.format(os.path.basename(feedstock_dir))

                # Try to get team or create it if it doesn't exist.
                team = teams.get(team_name)
                if not team:
                    team = create_team(
                        conda_forge,
                        team_name,
                        'The {} {} contributors!'.format(choice(superlative), team_name),
                        repo_names=[repo_name]
                    )
                    teams[team_name] = team
                    current_maintainers = []
                else:
                    current_maintainers = team.get_members()

                # Add only the new maintainers to the team.
                current_maintainers_handles = set([each_maintainers.login.lower() for each_maintainers in current_maintainers])
                for new_maintainer in maintainers - current_maintainers_handles:
                    headers, data = team._requester.requestJsonAndCheck(
                        "PUT",
                        team.url + "/memberships/" + new_maintainer
                    )
                # Mention any maintainers that need to be removed (unlikely here).
                for old_maintainer in current_maintainers_handles - maintainers:
                    print("AN OLD MEMBER ({}) NEEDS TO BE REMOVED FROM {}".format(old_maintainer, repo_name))

            # Remove this recipe from the repo.
            removed_recipes.append(name)
            if is_merged_pr:
                subprocess.check_call(['git', 'rm', '-r', recipe_dir])

    # Add new conda-forge members to all-members team. Welcome! :)
    if conda_forge:
        team_name = 'all-members'
        team = teams.get(team_name)
        if not team:
            team = create_team(
                conda_forge,
                team_name,
                'All of the awesome conda-forge contributors!',
                []
            )
            teams[team_name] = team
            current_members = []
        else:
            current_members = team.get_members()

        # Add only the new members to the team.
        current_members_handles = set([each_member.login.lower() for each_member in current_members])
        for new_member in all_maintainers - current_members_handles:
            print("Adding a new member ({}) to conda-forge. Welcome! :)".format(new_member))
            headers, data = team._requester.requestJsonAndCheck(
                "PUT",
                team.url + "/memberships/" + new_member
            )

    # Commit any removed packages.
    subprocess.check_call(['git', 'status'])
    if removed_recipes:
        subprocess.check_call(['git', 'checkout', os.environ.get('TRAVIS_BRANCH')])
        msg = ('Removed recipe{s} ({}) after converting into feedstock{s}. '
               '[ci skip]'.format(', '.join(removed_recipes),
                         s=('s' if len(removed_recipes) > 1 else '')))
        if is_merged_pr:
            # Capture the output, as it may contain the GH_TOKEN.
            out = subprocess.check_output(['git', 'remote', 'add', 'upstream_with_token',
                                           'https://conda-forge-manager:{}@github.com/conda-forge/staged-recipes'.format(os.environ['GH_TOKEN'])],
                                          stderr=subprocess.STDOUT)
            subprocess.check_call(['git', 'commit', '-m', msg])
            # Capture the output, as it may contain the GH_TOKEN.
            out = subprocess.check_output(['git', 'push', 'upstream_with_token', os.environ.get('TRAVIS_BRANCH')],
                                          stderr=subprocess.STDOUT)
        else:
            print('Would git commit, with the following message: \n   {}'.format(msg))

    if gh:
        # Get our final rate limit info.
        print_rate_limiting_info(gh)
