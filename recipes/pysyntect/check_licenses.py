# -*- coding: utf-8 -*-

"""Verify that pysyntect dependency licenses are present."""

import os
import sys
import json
import glob
import os.path as osp

RECIPE_DIR = os.environ['RECIPE_DIR']

BASE_GLOB = '{0}-LICENSE.*'
DEPENDENCIES = osp.join(RECIPE_DIR, 'dependencies.json')
LIBRARY_LICENSES = osp.join(RECIPE_DIR, 'library_licenses')


def main():
    deps = json.load(open(DEPENDENCIES, 'r'))
    for pkg in deps:
        pkg_name = pkg['name']
        pkg_glob = BASE_GLOB.format(pkg_name)
        matches = glob.glob(osp.join(LIBRARY_LICENSES, pkg_glob))
        if len(matches) == 0:
            print('License for the dependency {0} is '
                  'not being packaged'.format(pkg_name))
            sys.exit(1)


if __name__ == "__main__":
    main()
