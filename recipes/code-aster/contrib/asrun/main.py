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
This is the main file to access to astk services through as_run
"""

import os
import sys

from asrun.common.i18n import _

# ----- check Python version
if sys.hexversion < 0x020400F0:
    print("This script requires Python 2.4 or higher, sorry !")
    sys.exit(4)

from asrun.core         import magic
from asrun.run          import AsterRun
from asrun.system       import AsterSystem
from asrun.common.sysutils import local_full_host


def start():
    # ----- backward compatibility
    from asrun.backward_compatibility import change_argv
    sys.argv = change_argv(sys.argv)

    # ----- initialisation
    run = AsterRun()
    magic.run = run

    # ----- retrieve options and arguments
    opts, args = run.ParseArgs()
    # init magic
    magic.set_stdout(run['stdout'])
    magic.set_stderr(run['stderr'])
    magic.init_logger(filename=run['log_progress'], debug=run['debug'])
    run.current_action = opts.action

    if run.current_action == None:
        # if symbolic link "action" -> "as_run --action"
        alias = os.path.basename(sys.argv[0])
        if alias in list(run.actions_info.keys()):
            run.current_action = alias
        else:
            # default to 'run'
            run.current_action = 'run'
            #run.parser.error(_(u'you must specify an action'))

    # ----- get system commands
    run.DBG("Command line run on '%s'" % local_full_host,
            "using python executable '%s' :" % sys.executable,
             sys.argv)
    run.system = AsterSystem(run)
    run.PostConf()

    # ----- debug information
    if run['debug']:
        run.PrintConfig()
        print(_('Arguments :'), repr(args))
        print()

    # ----- start 'current_action'
    try :
        act = run.current_action
        if run.options['proxy'] is True:
            act = 'call_proxy'
        meth = run.actions_info[act]['method']
    except KeyError:
        run.Mess(_('dictionnary bad defined :')+' actions_info', '<F>_PROGRAM_ERROR')
    else:
        # trap <Control+C>
        try:
            meth(run, *args)
        except KeyboardInterrupt:
            run.Mess(_("'--%s' stopped by user") % run.current_action, '<F>_INTERRUPT')

    run.Sortie(0)


def main():
    if len(sys.argv) > 1 and sys.argv[1] == '--pdb':
        del sys.argv[1]
        import pdb
        pdb.run('start()')
    elif len(sys.argv) > 1 and sys.argv[1] == '--pudb':
        del sys.argv[1]
        import pudb
        pudb.runcall(start)
    else:
        start()
