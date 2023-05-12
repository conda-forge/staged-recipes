# -*- coding: utf-8 -*-

import sys
import os
import os.path as osp

from asrun.common.utils import get_absolute_dirname


# Code_Aster installation prefix (prefering ASTER_ROOT is at least necessary for asrun's developer!)
if os.environ.get('ASTER_ROOT'):
    aster_root = os.environ['ASTER_ROOT']
else:
    #               asrun           site-packages pythonX.Y      lib     prefix
    aster_root = osp.normpath(osp.join(
        get_absolute_dirname(__file__), os.pardir, os.pardir, os.pardir, os.pardir))
os.environ['ASTER_ROOT'] = aster_root

if os.environ.get('ASTER_ETC'):
    confdir = osp.join(os.environ['ASTER_ETC'], 'codeaster')
else:
    # directory for configuration files (profile.sh, config)
    # alternative to /etc/code_aster for non-root install
    prefix = aster_root
    if aster_root == '/usr':
        prefix = '/'
    confdir = osp.join(prefix, 'etc', 'codeaster')

# confdir contains plugins directory
if confdir not in sys.path:
    sys.path.append(confdir)

# directory containing data files
datadir = osp.join(aster_root, 'share', 'codeaster', 'asrun', 'data')

# directory for internationalization
localedir = osp.join(aster_root, 'share', 'locale')

# temporary directory
aster_tmpdir = os.environ.get('ASTER_TMPDIR', '/tmp')
os.environ['ASTER_TMPDIR'] = aster_tmpdir
