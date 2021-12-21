#!/usr/bin/env python

"""\
Dummy distutils setup script that provides version data for meta.yaml.
"""

import os
import sys
from distutils.core import setup

MYDIR = os.path.dirname(os.path.abspath(__file__))
SITESCONSDIR = os.path.abspath(os.path.join(MYDIR, '../site_scons'))
sys.path.insert(0, SITESCONSDIR)

from libdiffpybuildutils import gitinfo

ginfo = gitinfo()

setup(
    name='libdiffpy',
    version=ginfo['version'],
)
