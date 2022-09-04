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
Manage backward compatibility for astk < 1.6.0

- change_argv :
    Example :
        astk  1.6.0  :  as_run --info
        astk <1.6.0  :  as_serv as_info
"""

import sys
import os
import os.path as osp
import re
from warnings import warn, simplefilter


# DeprecationWarning are ignored in python2.7 by default
simplefilter('default')

# generic functions
def bwc_deprecate_class(old_class_name, new_class):
    """Deprecate a class"""
    def new_class_factory(*args, **kwargs):
        """Warn at initialization."""
        warn("'%s' class is deprecated, it is replaced by '%s'" \
             % (old_class_name, new_class.__name__),
             DeprecationWarning, stacklevel=3)
        return new_class(*args, **kwargs)
    return new_class_factory

def removed_feature(*args, **kwargs):
    """Fatal deprecation!"""
    raise NotImplementedError("this feature has been removed!")

dict_serv = {
    'as_info'         : '--info',
    'as_edit'         : '--edit',
    'as_actu'         : '--actu',
    'as_tail'         : '--tail',
    'as_del'          : '--del',
    'as_rex_creer'    : '--create_issue',
    'insert_in_db'    : '--insert_in_db',
    'as_exec'         : '--serv',
    'as_exec_special' : '--serv',
    'as_mail'         : '--sendmail',
}


def chg_as_mail(oldargv):
    """Changes for 'as_serv as_mail email_address file'.
    """
    argv = oldargv[:]
    if len(argv) > 2:
        argv[2] = '--report_to=%s' % argv[2]
    return argv


def change_argv(oldargv):
    """Change command line arguments
    """
    from asrun.parser import get_option_value
    # replace first argument (service) by corresponding option
    argv = oldargv[:]
    arg1 = ''
    if len(argv[1:]) > 0:
        arg1 = argv[1]
    if dict_serv.get(arg1) is not None:
        argv[1] = dict_serv[arg1]
    elif arg1 in ('as_exec', 'as_exec_special'):
        pass
    elif arg1 in ('tool_stanley', 'as_rex_consult', 'as_rex_modfic', 'as_rex_suppr'):
        warn("The service (%s) is not available any more. Update your ASTK client." % arg1,
             DeprecationWarning, stacklevel=2)
        sys.exit(2)

    if arg1 == 'as_mail':
        argv = chg_as_mail(argv)

    # change old style options (-KILL/-USR1)
    dict_change = {
        '-KILL' : '--signal=KILL',
        '-USR1' : '--signal=USR1',
    }
    ind = list(range(len(argv)))
    d = dict(list(zip(argv, ind)))
    for old, new in list(dict_change.items()):
        if d.get(old) is not None:
            argv[d[old]] = new

    #pylint: disable-msg=E1103
    # rcdir=xxx previously accepted a suffix, cause of confusion
    rcdir = get_option_value(argv, "--rcdir")
    rcdir0 = rcdir
    if rcdir is not None and not rcdir.startswith(".astkrc") and osp.abspath(rcdir) != rcdir:
        warn("rcdir option requires an absolute path or something similar to '.astkrc_xxx'",
             DeprecationWarning, stacklevel=2)
        rcdir = ".astkrc_%s" % rcdir
        for i, v in enumerate(argv):
            if v.find("--rcdir=") > -1:
                argv[i] = "--rcdir=%s" % rcdir
                warn("rcdir argument %s changed to %s" % (rcdir0, argv[i]),
                     SyntaxWarning, stacklevel=2)

    # warn
    if argv != oldargv:
        s_old = ' '.join(oldargv)
        argv2 = argv[:]
        if argv2[0].endswith('as_serv'):
            argv2[0] = re.sub('as_serv$', 'as_run', argv2[0])
        s_new = ' '.join(argv2)

        msg = """command line %s is deprecated, please use %s instead.""" % (s_old, s_new)
        warn(msg, DeprecationWarning, stacklevel=2)
    return argv


# 1.7.12 > 1.8.0
def read_rcfile(*args, **kwargs):
    warn('read_rcfile moved to asrun.common.rcfile', DeprecationWarning, stacklevel=2)
    from asrun.common.rcfile import read_rcfile
    return read_rcfile(*args, **kwargs)

def parse_config(*args, **kwargs):
    warn('parse_config moved to asrun.common.rcfile', DeprecationWarning, stacklevel=2)
    from asrun.common.rcfile import parse_config
    return parse_config(*args, **kwargs)

# 1.8.0 > 1.8.1
def get_timeout(prof):
    warn('get_timeout is now a method of AsterProfil object', DeprecationWarning,
        stacklevel=2)
    return prof.get_timeout()

def add_param(prof, dict_para):
    warn('add_param is now a method of AsterProfil object named add_param_from_dict',
        DeprecationWarning, stacklevel=2)
    return prof.add_param_from_dict(dict_para)

def get_hostrc(run, prof):
    warn('get_hostrc moved to asrun.repart', DeprecationWarning, stacklevel=2)
    from asrun.repart import get_hostrc
    return get_hostrc(run, prof)

# 1.8.3 > 1.8.4
def bwc_edit_args(args):
    if len(args) > 4:
        warn("'as_run --edit' does not support display argument anymore",
            DeprecationWarning, stacklevel=2)
    return args[:4]

# 1.9.1 > 1.9.2
def bwc_getop(repl, *args, **kwargs):
    warn("'as_run --getop' is deprecated (it was really a bad name !), "\
        "use 'showop' instead.",
        DeprecationWarning, stacklevel=2)
    repl(*args, **kwargs)

def bwc_config_rc(oldrc, func_read):
    """Move config resources file."""
    if not osp.isfile(oldrc):
        return
    newrc = osp.join(osp.dirname(oldrc), 'prefs')
    suffix = '.deprecated_in_1.10.0'
    saved = osp.basename(oldrc) + suffix
    warn("the resources file '%s' is deprecated, it is replaced by '%s' "\
         "(saved under '%s')." % (oldrc, newrc, saved),
         DeprecationWarning, stacklevel=2)
    # read old file
    dold = {}
    func_read(oldrc, dold, mcsimp=['vers', 'noeud'])
    dnew = {}
    if osp.isfile(newrc):
        func_read(newrc, dnew, mcsimp=['vers', 'noeud'])
        toadd = []
        for key in list(dold.keys()):
            if dnew.get(key) is None:
                toadd.append('%s : %s' % (key, dold[key]))
            elif dold[key] != dnew[key]:
                warn("value for '%s' was '%s' and is '%s' in '%s'" \
                     % (key, dold[key], dnew[key], newrc),
                     stacklevel=2)
        if len(toadd) > 0:
            with open(newrc, 'r') as f:
                txt = f.read()
            txt += """
# values from deprecated file '%s'
%s
""" % (oldrc, os.linesep.join(toadd))
            try:
                with open(newrc, 'w') as f:
                    f.write(txt)
            except (IOError, OSError):
                warn("no sufficient permissions to write the file '%s'" % newrc,
                     RuntimeWarning, stacklevel=2)
    try:
        os.rename(oldrc, oldrc + suffix)
    except:
        warn("no sufficient permissions to rename the file '%s'" % oldrc,
             RuntimeWarning, stacklevel=2)

def bwc_client_rcname(fname):
    """Deprecate 'config' file."""
    if fname != 'config':
        return fname
    new = 'prefs'
    warn("the resources file '%s' is deprecated, it is replaced by '%s' "\
         % (fname, new),
         DeprecationWarning, stacklevel=3)
    return new

def bwc_client_deprecate_run(run):
    """Deprecate run argument of ClientConfig."""
    if run is not None:
        warn("'run' argument is deprecated at ClientConfig initialization",
             DeprecationWarning, stacklevel=3)

def bwc_get_version(newfunc, run, REPREF):
    """Deprecate 'get_version' function."""
    warn("'get_version(run, REPREF)' is deprecated and replaced by " \
         "get_aster_version(version_name).",
         DeprecationWarning, stacklevel=2)
    return newfunc(REPREF)
