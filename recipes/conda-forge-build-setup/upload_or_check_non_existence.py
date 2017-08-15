#!/usr/bin/env python
from __future__ import print_function

import argparse
import hashlib
import os
import subprocess
import sys

from binstar_client.utils import get_binstar
import binstar_client.errors
import conda.config
from conda.api import get_index
from conda_build.metadata import MetaData
from conda_build.build import bldpkg_path
from conda_build.config import Config


def built_distribution_already_exists(cli, meta, owner):
    """
    Checks to see whether the built recipe (aka distribution) already
    exists on the owner/user's binstar account.

    """
    distro_name = '{}/{}.tar.bz2'.format(conda.config.subdir, meta.dist())
    try:
        config = Config()
        fname = bldpkg_path(meta, config)
    except TypeError:
        # conda-build < 2.0.0 takes a single config argument
        fname = bldpkg_path(meta)
    try:
        dist_info = cli.distribution(owner, meta.name(), meta.version(),
                                     distro_name)
    except binstar_client.errors.NotFound:
        dist_info = {}

    exists = bool(dist_info)
    # Unfortunately, we cannot check the md5 quality of the built distribution, as
    # this will depend on fstat information such as modification date (because
    # distributions are tar files). Therefore we can only assume that the distribution
    # just built, and the one on anaconda.org are the same.
#    if exists:
#        md5_on_binstar = dist_info.get('md5')
#        with open(fname, 'rb') as fh:
#            md5_of_build = hashlib.md5(fh.read()).hexdigest()
#
#        if md5_on_binstar != md5_of_build:
#            raise ValueError('This build ({}), and the build already on binstar '
#                             '({}) are different.'.format(md5_of_build, md5_on_binstar))
    return exists


def upload(cli, meta, owner, channels):
    try:
        with open('binstar.token', 'w') as fh:
            fh.write(cli.token)
        subprocess.check_call(['anaconda', '--quiet', '-t', 'binstar.token',
                               'upload', bldpkg_path(meta),
                               '--user={}'.format(owner),
                               '--channel={}'.format(channels)],
                              env=os.environ)
    finally:
        os.remove('binstar.token')


def distribution_exists_on_channel(binstar_cli, meta, owner, channel='main'):
    """
    Determine whether a distribution exists on a specific channel.

    Note from @pelson: As far as I can see, there is no easy way to do this on binstar.

    """
    fname = '{}.tar.bz2'.format(meta.dist())
    channel_url = '/'.join([owner, 'label', channel])

    distributions_on_channel = get_index([channel_url],
                                         prepend=False, use_cache=False)

    try:
        on_channel = (distributions_on_channel[fname]['subdir'] ==
                      conda.config.subdir)
    except KeyError:
        on_channel = False

    return on_channel


def main():
    token = os.environ.get('BINSTAR_TOKEN')

    description = ('Upload or check consistency of a built version of a '
                   'conda recipe with binstar. Note: The existence of the '
                   'BINSTAR_TOKEN environment variable determines '
                   'whether the upload should actually take place.')
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument('recipe_dir', help='the conda recipe directory')
    parser.add_argument('owner', help='the binstar owner/user')
    parser.add_argument('--channel', help='the binstar channel', default='main')
    args = parser.parse_args()
    recipe_dir, owner, channel = args.recipe_dir, args.owner, args.channel

    cli = get_binstar(argparse.Namespace(token=token, site=None))
    meta = MetaData(recipe_dir)
    if meta.skip():
        print("No upload to take place - this configuration was skipped in build/skip.")
        return
    exists = built_distribution_already_exists(cli, meta, owner)
    if token:
        if not exists:
            upload(cli, meta, owner, channel)
            print('Uploaded {}'.format(bldpkg_path(meta)))
        else:
            print('Distribution {} already \nexists for {}.'
                  ''.format(bldpkg_path(meta), owner))
    else:
        print("No BINSTAR_TOKEN present, so no upload is taking place. "
              "The distribution just built {} already available for {}."
              "".format('is' if exists else 'is not', owner))

if __name__ == '__main__':
    main()
