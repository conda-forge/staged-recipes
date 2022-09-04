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
This package includes build and control systems for Code_Aster solver.

The API for external tools is defined here to provide an access to the most of
the asrun services.
"""

from asrun.__pkginfo__ import version as __version__

# This flag indicates that this installation only supports Python 3.
PY3_ONLY = True

def create_run_instance(**kwargs):
    """Return a new AsterRun instance.

    Arguments:
        kwargs (dict): Dict of options passed to the constructor.
    """
    from asrun.run import AsRunFactory
    return AsRunFactory(**kwargs)

def create_client(rcdir):
    """Return a new ClientConfig instance.

    Arguments:
        rcdir (str): Name of the resources directory to be used.
    """
    from asrun.client import ClientConfig
    return ClientConfig(rcdir)

def create_calcul_handler(prof):
    """Return a AsterCalcHandler to process a calculation.

    Arguments:
        prof (AsterProfil): Profil of the calculation.
    """
    from asrun.client import AsterCalcHandler
    return AsterCalcHandler(prof)

def create_profil(filename=None, **kwargs):
    """Return a AsterProfil object from a file."""
    from asrun.profil import AsterProfil
    return AsterProfil(filename, **kwargs)
