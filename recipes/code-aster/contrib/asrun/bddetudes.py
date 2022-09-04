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
Insert an execution into a database.
"""

from asrun.common.i18n import _
from asrun.common_func  import get_tmpname


def SetParser(run):
    """Configure the command-line parser, add options name to store to the list,
    set actions informations.
    run : AsterRun object which manages the execution
    """
    acts_descr = {
        'insert_in_db' : {
            'method' : Insert,
            'syntax' : 'export_file',
            'help'   : _('prepare the profile to insert an execution into a database.')
        },
    }
    #opts_descr = {}
    title = _('Options for astketud database link')
    run.SetActions(
            actions_descr=acts_descr,
            actions_order=['insert_in_db'],
            group_options=False, group_title=title, actions_group_title=False,
            #options_descr=opts_descr,
    )


def Insert(run, *args):
    """Insert an execution to the database.
    """
    if len(args) != 1:
        run.parser.error(_("'--%s' takes exactly %d arguments (%d given)") % \
            (run.current_action, 1, len(args)))

    iret = 0
    if not run.config.get('astketud'):
        run.Mess(_("'astketud' is not defined in 'agla' configuration file."), '<F>_AGLA_ERROR')

    # 1. copy export file
    jn = run['num_job']
    fprof = get_tmpname(run, run['tmp_user'], basename='etude_prof')
    kret = run.Copy(fprof, args[0], niverr='<F>_PROFILE_COPY')

    # 2. insert study in database
    cmd = '%(astketud)s %(profile)s' % {
        'astketud' : run['astketud'],
        'profile'  : fprof,
    }
    iret, output = run.Shell(cmd)
    if iret != 0:
        run.Mess(output, '<F>_DB_ERROR')
    # astketud always returns exit=0 !
    else:
        print(output)
