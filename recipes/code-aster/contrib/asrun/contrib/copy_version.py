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

"""%prog [options] source destination

This module allows to copy/create a Code_Aster version 'source' to another 'destination'.
"""

import os.path as osp
from optparse import OptionParser

from asrun.common.i18n import _
from asrun.mystring import ufmt
from asrun.run import AsRunFactory
from asrun.config import build_config_of_version


def duplicate_with_symlinks(orig, dest):
    """"""
    run = AsRunFactory()
    rorig = run.get_version_path(orig)
    rdest = run.get_version_path(dest)
    run.Mess(ufmt(_("copying %s to %s..."), rorig, rdest))
    run.MkDir(dest)
    conf0 = build_config_of_version(run, orig)
    keys = list(conf0.keys())
    lsrc = set([conf0.get_with_absolute_path(k)[0] for k in keys if k.startswith('SRC')])
    lsrc.add(conf0.get_with_absolute_path('REPMAT')[0])
    lsrc.add(conf0.get_with_absolute_path('REPDEX')[0])
    lsrc.update(conf0.get_with_absolute_path('ENV_SH'))
    for src in lsrc:
        basn = osp.basename(src)
        if osp.exists(src) \
        and osp.exists(osp.join(rorig, basn)) \
        and not osp.exists(osp.join(rdest, basn)):
            run.Symlink(src, osp.join(rdest, basn))
    dconf = osp.join(rdest, osp.basename(conf0.get_filename()))
    if not osp.exists(dconf):
        run.Copy(rdest, conf0.get_filename(), verbose=True)


def main():
    """Parse command line arguments"""
    parser = OptionParser(usage=__doc__)
    parser.add_option('-g', '--debug', action='store_true', dest='debug',
        help="add debug informations")
    parser.add_option('-s', action='store_true', dest='symlink', default=True,
        help="create symlinks instead of copying source directories (except for config.txt)")
    opts, args = parser.parse_args()
    if len(args) != 2:
        parser.error("two arguments required!")
    orig, dest = args
    if opts.symlink:
        duplicate_with_symlinks(orig, dest)
    else:
        parser.error('invalid command')

if __name__ == '__main__':
    main()
