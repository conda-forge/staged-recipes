# -*- coding: utf-8 -*-

# ==============================================================================
# COPYRIGHT (C) 1991 - 2015  EDF R&D                  WWW.CODE-ASTER.ORG
# THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
# IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
# THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
# (AT YOUR OPTION) ANY LATER VERSION.
#
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
# GENERAL PUBLIC LICENSE FOR MORE DETAILS.
#
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
# ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
#    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
# ==============================================================================

"""
Tools for developpers :
    - search available routines numbers (te, op, lc...)
"""


import os.path as osp
from glob import glob

from asrun.common.i18n import _
from asrun.config import build_config_of_version



def _get_available_routine(templ, max, format):
    """Return the list of available routines numbers."""
    lavail = []
    for f in glob(templ):
        fobj = open(f, 'rb')
        for line in fobj:
            if 'FERMETUR_' in line:
                lavail.append(osp.basename(f))
                break
        fobj.close()
    lavail.sort()
    return lavail


def get_available_te(bibfor):
    """Return the list of available te routines numbers."""
    templ = osp.join(bibfor, '*', 'te[0-9]*.F90')
    return _get_available_routine(templ, 600, "te%04d.F90")


def get_available_op(bibfor):
    """Return the list of available te routines numbers."""
    templ = osp.join(bibfor, '*', 'op[0-9]*.F90')
    return _get_available_routine(templ, 200, "op%04d.F90")


def get_available_lc(bibfor):
    """Return the list of available te routines numbers."""
    templ = osp.join(bibfor, '*', 'lc[0-9]*.F90')
    return _get_available_routine(templ, 200, "lc%04d.F90")


def FreeSubroutines(run, *args):
    """Return available subroutines numbers.
    """
    MAX = 8
    if not run.get('aster_vers'):
        run.parser.error(_("You must define 'default_vers' in 'aster' configuration file or use '--vers' option."))
    fconf = run.get('config')
    if fconf:
        fconf = osp.abspath(fconf)
    conf = build_config_of_version(run, run['aster_vers'], fconf)

    if run['nolocal']:
        run.Mess(_('This operation only works on local source files. "--nolocal" option ignored'))

    bibfor = conf.get_with_absolute_path('SRCFOR')[0]

    lte = get_available_te(bibfor)
    lop = get_available_op(bibfor)
    llc = get_available_lc(bibfor)
    if not run.get('all_test'):
        lte = lte[:MAX]
        lop = lop[:MAX]
        llc = llc[:MAX]
    print(_('List of the available TE subroutines :'))
    print(' '.join(lte))
    print()
    print(_('List of the available OP subroutines :'))
    print(' '.join(lop))
    print()
    print(_('List of the available LC subroutines :'))
    print(' '.join(llc))
