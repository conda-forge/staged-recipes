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

"""usage: as_run --serv [options] user@mach:/nom_profil.export

old syntax : as_serv as_exec [options] user@mach:/nom_profil.export

Export file must be the last argument.

Object :
    - retreive the export file from the client
    - read export and ...
    - ... call as_run on the right node, into a xterm or not,
     now or differed...
"""

import os.path as osp
from optparse  import SUPPRESS_HELP

from asrun.common.i18n  import _
from asrun.core         import magic
from asrun.mystring     import ufmt
from asrun.calcul       import AsterCalcul
from asrun.profil       import AsterProfil
from asrun.plugins.actions import ACTIONS
from asrun.common_func  import get_tmpname
from asrun.common.utils import get_plugin


def SetParser(run):
    """Configure the command-line parser, add options name to store to the list,
    set actions informations.
    run : AsterRun object which manages the execution
    """
    acts_descr = {
        'serv' : {
            'method' : Serv,
            'syntax' : 'user@mach:/nom_profil.export',
            'help'   : _('start an execution (calling as_run in a separate process)')
        },
        'call_proxy' : {
            'method' : ProxyToServer,
            'help'   : SUPPRESS_HELP,
        },
        'get_results' : {
            'method' : None,
            'help'   : SUPPRESS_HELP,
        },
        'sendmail'  : {
            'method' : SendMail,
            'syntax' : '[--report_to=EMAIL1,EMAIL2] filename',
            'help'   : _('Send the content of "filename" (may be on a remote host) to '\
                          'EMAIL1,EMAIL2,...')
        },
    }
    opts_descr = {
        'proxy' : {
            'args'   : ('--proxy', ),
            'kwargs' : {
                'action'  : 'store_true',
                'default' : False,
                'dest'    : 'proxy',
                'help'    : _('call a server to run the specified action '
                    '(for example, calling as_run --serv on the server)')
            }
        },
        'schema' : {
            'args'   : ('--schema', ),
            'kwargs' : {
                'action'  : 'store',
                'default' : '',
                'dest'    : 'schema',
                'help'    : _('allow to modify asrun behavior using an alternative schema')
            }
        },
    }
    run.SetActions(
            actions_descr = acts_descr,
            actions_order = ['serv', 'call_proxy', 'sendmail', 'get_results'],
            group_options=False,
            options_descr = opts_descr,
    )


def Serv(run, *args):
    """Start an execution, another as_run, in a separate process (but on the same server/cluster).
    """
    # check argument
    if len(args) != 1:
        run.parser.error(_("'--%s' requires one argument") % run.current_action)

    service = AsterCalcul(run, filename=args[0])
    iret, bid = service.start()
    # prinf job info
    print("JOBID=%s QUEUE=%s STUDYID=%s" % (service.jobid, service.queue, service.studyid))

    run.Sortie(iret)


def SendMail(run, *args):
    """Send the content of a file by mail.
    """
    # check argument
    if len(args) != 1:
        run.parser.error(_("'--%s' requires one argument") % run.current_action)

    # content file
    fcontent = get_tmpname(run, run['tmp_user'], basename='mail_content')
    run.ToDelete(fcontent)
    kret = run.Copy(fcontent, args[0], niverr='<F>_PROFILE_COPY')

    if run['report_to'] == '':
        run.Mess(_("no email address provided !"), '<F>_ERROR')

    with open(fcontent, 'r') as f:
        run.SendMail(dest=run['report_to'], text=f.read(),
                 subject='From as_run/SendMail')


def ProxyToServer(run, *args):
    """Work as a proxy to a server to run an action.

    An export file is required to get the informations to connect the server.
    If the action has not a such argument, it will be the first for calling
    through the proxy. The other arguments are those of the action.

    This option is intended to be called on a client machine (directly
    by the gui for example).
    """
    # The options must be passed explictly for each action because their
    # meaning are not necessarly the same on client and server sides.
    # Example : "num_job" of client has no sense on the server.
    # An options list can be added to ACTIONS definitions.
    magic.log.info('-'*70)
    run.DBG("'--proxy' used for action '%s' and args : %s" % (run.current_action, args))
    dact = ACTIONS.get(run.current_action)
    # check argument
    if dact is None:
        run.parser.error(_("these action can not be called through the proxy : '--%s'") \
            % run.current_action)
    if not (dact['min_args'] <= len(args) <= dact['max_args']):
        run.parser.error(_("'--%s' : wrong number of arguments (min=%d, max=%d)") \
            % (run.current_action, dact['min_args'], dact['max_args']))
    # read export from arguments
    prof = None
    if dact['export_position'] < len(args):
        profname = args[dact['export_position']]
        fprof = run.PathOnly(profname)
        if fprof != profname:
            run.DBG("WARNING: --proxy should be called on a local export file, not %s" % profname)
            fprof = get_tmpname(run, run['tmp_user'], basename='profil_astk')
            iret = run.Copy(fprof, profname, niverr='<F>_PROFILE_COPY')
            run.ToDelete(fprof)
        if fprof == "None":
            # the client knows that the schema does not need an export file
            fprof = None
        elif not osp.isfile(fprof):
            run.Mess(ufmt(_('file not found : %s'), fprof), '<F>_FILE_NOT_FOUND')
        prof = AsterProfil(fprof, run)
        if fprof is not None:
            run.DBG("Input export : %s" % fprof, prof)

    iret = call_plugin(run.current_action, prof, *args)
    if type(iret) in (list, tuple):
        iret = iret[0]
    run.Sortie(iret)


def call_plugin(action, prof, *args):
    """Wrapper to import and run a plugin."""
    # the schema can be forced using the --schema option.
    schema_name = magic.run['schema'] \
        or ACTIONS[action]['default_schema']
    try:
        schem = get_plugin(schema_name)
    except ImportError:
        magic.run.Mess(ufmt(_('can not import : %s'), schema_name), '<F>_FILE_NOT_FOUND')
    iret = schem(prof, args)
    return iret
