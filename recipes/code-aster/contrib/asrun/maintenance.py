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
Tools to maintain a development version of Code_Aster, and useful for
the developper.
Methods are called by an AsterRun object.
"""

import os
import os.path as osp
import re
import glob
import tarfile
import pickle
import traceback
from optparse  import SUPPRESS_HELP
from pprint    import pformat
from functools import partial
from warnings import warn

from asrun.installation import aster_root
from asrun.common.i18n import _
from asrun.mystring     import ufmt
from asrun.core         import RunAsterError, magic
from asrun.config       import build_config_of_version
from asrun.build        import AsterBuild
from asrun.profil       import AsterProfil
from asrun.system       import local_host
from asrun.execution    import build_test_export
from asrun.testlist     import TestList
from asrun.runner       import Runner
from asrun.toolbox      import GetInfos
from asrun.common_func  import get_tmpname, get_devel_param, edit_file
from asrun.dev          import GetMessageInfo, FreeSubroutines
from asrun.common.utils import force_list, get_list, remove_empty_dirs

from asrun.backward_compatibility import bwc_getop, bwc_get_version


def SetParser(run):
    """Configure the command-line parser, add options name to store to the list,
    set actions informations.
    run : AsterRun object which manages the execution
    """
    acts_descr = {
        'getop'        : {
            'method' : GetOP,
            'syntax' : '[options] commande[.capy]',
            'help'   : _('Return the main subroutine of a Code_Aster command')
        },
        'showop'        : {
            'method' : ShowOP,
            'syntax' : '[options] commande[.capy]',
            'help'   : _('Show the main subroutine of a Code_Aster command')
        },
        'show'         : {
            'method' : Show,
            'syntax' : '[options] obj1 [obj2...]',
            'help'   : _('Show a source file : fortran, C, python, capy, cata, histor or test')
        },
        'get'          : {
            'method' : Get,
            'syntax' : '[options] obj1 [obj2...]',
            'help'   : _('Copy a source file in current directory')
        },
        'diff'         : {
            'method' : Diff,
            'syntax' : '[options] obj1 [obj2...]',
            'help'   : _('Show the diff of a source file : fortran, C, python, capy, cata or test')
        },
        'update'       : {
            'method' : Update,
            'syntax' : '[options] fich1.tar.gz [fich2.tar.gz...]',
            'help'   : _('Perform one or several updates of a development version')
        },
        'make'         : {
            'method' : MakeAster,
            'syntax' : '[--vers=VERS] [target]',
            'help'   : _('Build a Code_Aster version (executable, libraries, catalogues). ' \
                          '`target` may be all or clean')
        },
        'auto_update'  : {
            'method' : AutoUpdate,
            'syntax' : '[--vers=...] [--force_upgrade] [--keep_increment] [--local] [last_version]',
            'help'   : _('Download available updates from a server and apply them to the ' \
                          'current development version up to `last_version`.')
        },
        'getversion'   : {
            'method' : GetVersion,
            'syntax' : '[options]',
            'help'   : _('Return current release number of the default version')
        },
        'getversion_path'   : {
            'method' : GetVersionPath,
            'syntax' : '[options]',
            'help'   : _('Return the path of the default version')
        },
        'diag'         : {
            'method' : MakeDiag,
            'syntax' : '[--astest_dir=DIR1,[DIR2]] [--test_list=LIST] [--only_nook] ' \
                       '[diag_result.pick]',
            'help'   : _('Build the diagnosis of Code_Aster testcases (from DIR or default ' \
                          'astest directory) and write a pickled file of the result.')
        },
        'ctags'         : {
            'method' : GenCtags,
            'syntax' : '[--vers=VERS]',
            'help'   : _('Build ctags file')
        },
        'list'         : {
            'method' : TestList,
            'syntax' : '[--all] [--test_list=FILE] [--filter=...] [--command=...] ' \
                    '[--user_filter=...] [--output=FILE] [test1 [test2 ..]]',
            'help'   : _('Build a list of testcases using a list of command/keywords and/or ' \
                          'verifying some criterias about cputime or memory.')
        },
        'messages'  : {
            'method' : GetMessageInfo,
            'syntax' : 'subroutine | message_number | check [--fort=...] [--python=...] ' \
                       '[--unigest=...] | move old_msgid new_msgid',
            'help'   : _('Operation on Code_Aster messages catalogues. subroutine = returns ' \
                          'messages called by "subroutine". message_number = returns subroutines ' \
                          'calling this message. check = check messages catalogues and print ' \
                          'some stats. move = move a message from a catalogue to another and ' \
                          'produce new catalogues and new source files.')
        },
        'free_sub' : {
            'method' : FreeSubroutines,
            'syntax' : '[--all]',
            'help' : _('Return the available numbers for the routines TE, OP, LC... ' \
                        'Return the first 8 items except if --all is present.'),
        },
        'get_export' : {
            'method' : GetExport,
            'syntax' : 'testcase_name',
            'help'   : _('Build an export file to run a testcase and print it to stdout'),
        },
        'get_infos' : {
            'method' : GetInfos,
            'syntax' : '[--output=FILE] host1 [host2 [...]]',
            'help'   : _('Return cpu and memory informations about given hosts'),
        },
        'showme'        : {
            'method' : ShowMe,
            'syntax' : '[options] bin|lib|etc|data|locale|param [parameter name]',
            'help'   : _('Print informations about installation and configuration')
        },
    }
    opts_descr = {
        'local' : {
            'args'   : ('-l', '--local'),
            'kwargs' : {
                'action'  : 'store_true',
                'default' : False,
                'dest'    : 'local',
                'help'    : _('files will not been searched on a server but on the local machine')
            }
        },
        'nolocal' : {
            'args'   : ('--nolocal', ),
            'kwargs' : {
                'action'  : 'store_true',
                'default' : False,
                'dest'    : 'nolocal',
                'help'    : _('force remote files search (reverse of --local)')
            }
        },
        'vers' : {
            'args'   : ('--vers', ),
            'kwargs' : {
                'type'    : 'string',
                'default' : run.get_version_path(run.get('default_vers')),
                'action'  : 'store',
                'dest'    : 'aster_vers',
                'metavar' : 'VERS',
                'help'    : _('Code_Aster version to used (for get, show, showop)')
            }
        },
        'version_dev' : {
            'args'   : ('--version_dev', ),
            'kwargs' : {
                # kept for backward compatibility, replace by --vers
                'help'    : SUPPRESS_HELP,
                'type'    : 'string',
                'default' : None,
                'action'  : 'store',
                'dest'    : 'version_dev',
                'metavar' : 'VERS',
            }
        },
        'all' : {
            'args'   : ('-a', '--all'),
            'kwargs' : {
                'default' : False,
                'action'  : 'store_true',
                'dest'    : 'all_test',
                'help'    : _('get all the files of the test')
            }
        },
        'astest_dir' : {
            'args'   : ('--astest_dir', ),
            'kwargs' : {
                'type'    : 'string',
                'action'  : 'store',
                'dest'    : 'astest_dir',
                'metavar' : 'DIR',
                'help'    : _('testcases directory to watch')
            }
        },
        'only_nook' : {
            'args'   : ('--only_nook', ),
            'kwargs' : {
                'default' : False,
                'action'  : 'store_true',
                'dest'    : 'only_nook',
                'help'    : _('report only errors (but time spent by passed testcases ' \
                               'is included)')
            }
        },
        'test_list' : {
            'args'   : ('--test_list', ),
            'kwargs' : {
                'action'  : 'store',
                'dest'    : 'test_list',
                'metavar' : 'FILE',
                'help'    : _('list of the testcases')
            }
        },
        'force_upgrade' : {
            'args'   : ('--force_upgrade',),
            'kwargs' : {
                'action'  : 'store_true',
                'default' : False,
                'dest'    : 'force_upgrade',
                'help'    : _('Force upgrade to the next release (for example from 10.1.xx ' \
                               'to 10.2.0)')
            }
        },
        'keep_increment' : {
            'args'   : ('--keep_increment',),
            'kwargs' : {
                'action'  : 'store_true',
                'default' : False,
                'dest'    : 'keep_increment',
                'help'    : _('update a version increment by increment and keep intermediate ' \
                               'executable')
            }
        },
        'report_to' : {
            'args'   : ('--report_to', ),
            'kwargs' : {
                'type'    : 'string',
                'default' : '',
                'action'  : 'store',
                'dest'    : 'report_to',
                'metavar' : 'EMAIL',
                'help'    : _('email address to send the report of a execution (only used ' \
                               'for --auto_update)')
            }
        },
        'config' : {
            'args'   : ('--config', ),
            'kwargs' : {
                'action'  : 'store',
                'dest'    : 'config',
                'metavar' : 'FILE',
                'help'    : _('use another "config.txt" file (only used for make, update ' \
                               'and auto_update).')
            }
        },
        'command' : {
            'args'   : ('--command', ),
            'kwargs' : {
                'action'  : 'append',
                'dest'    : 'command',
                'metavar' : 'COMMANDE[/MOTCLEFACT[/MOTCLE[=VALEUR]]]',
                'help'    : _('keep testcases using the given command and keywords.')
            }
        },
        'search' : {
            'args'   : ('--search', ),
            'kwargs' : {
                'action'  : 'append',
                'dest'    : 'search',
                'metavar' : 'REGEXP',
                'help'    : _('keep testcases matching the given regular expression (or ' \
                               'simple string).')
            }
        },
        'filter' : {
            'args'   : ('--filter', ),
            'kwargs' : {
                'action'  : 'append',
                'dest'    : 'filter',
                'help'    : _("""filters applied to the testcases parameters : """ \
                               """'nom_para < valeur' (supported comparison <, >, =)."""),
            }
        },
        'user_filter' : {
            'args'   : ('--user_filter', ),
            'kwargs' : {
                'action'  : 'store',
                'dest'    : 'user_filter',
                'metavar' : 'FILE',
                'help'    : _("""file containing testlist.FILTRE classes. """ \
                     """See [...]/share/codeaster/asrun/examples/user_filter.py for an example."""),
            }
        },
        'surch_fort' : {
            'args'   : ('--surch_fort', ),
            'kwargs' : {
                'action'  : 'store',
                'dest'    : 'surch_fort',
                'metavar' : 'REP',
                'help'    : _("""one or more directories (comma separated) containing """ \
                               """additionnal fortran source files"""),
            }
        },
        'surch_pyt' : {
            'args'   : ('--surch_pyt', ),
            'kwargs' : {
                'action'  : 'store',
                'dest'    : 'surch_pyt',
                'metavar' : 'REP',
                'help'    : _("""one or more directories (comma separated) containing """ \
                               """additionnal python source files"""),
            }
        },
        'unigest' : {
            'args'   : ('--unigest', ),
            'kwargs' : {
                'action'  : 'store',
                'dest'    : 'unigest',
                'metavar' : 'FILE',
                'help'    : _("""a unigest file (for deletion)"""),
            }
        },
        'output' : {
            'args'   : ('-o', '--output',),
            'kwargs' : {
                'action'  : 'store',
                'dest'    : 'output',
                'metavar' : 'FILE',
                'help'    : _("""redirect the result to FILE instead of stdout.""")
            }
        },
        'destdir' : {
            'args'   : ('--destdir',),
            'kwargs' : {
                'action'  : 'store',
                'dest'    : 'destdir',
                'metavar' : 'DIR',
                'help'    : _("""fake root directory where files will be copied"""),
            }
        },
    }
    title = _('Options for maintenance operations')
    run.SetActions(
            actions_descr=acts_descr,
            actions_order=['show', 'get', 'diff', 'showop', 'get_export',
                    'free_sub', 'list', 'diag', 'messages', 'get_infos',
                    'getversion', 'getversion_path',
                    'make', 'update', 'auto_update',
                    'ctags', 'showme',
                    # backward compatibility
                    'getop'],
            group_options=True, group_title=title, actions_group_title=False,
            options_descr=opts_descr
    )


def ShowOP(run, *list_capy):
    """Return the main subroutine of a command.
    """
    run.check_version_setting()
    REPREF = run.get_version_path(run['aster_vers'])
    if len(list_capy) < 1:
        run.parser.error(
                _("'--%s' requires one or more arguments") % run.current_action)
    run.PrintExitCode = False
    conf = build_config_of_version(run, run['aster_vers'])
    for capy in list_capy:
        capy = capy.replace('.capy', '')
        nf = os.path.join(REPREF, conf['SRCCAPY'][0], 'commande', capy + '.capy')
        if not os.path.exists(nf):
            run.Mess(ufmt(_('file not found : %s'), nf), '<A>_ALARM')
            run.Mess(_("'--%s' search capy files on local machine") \
                    % run.current_action)
            break
        with open(nf, 'r') as f:
            txt = f.read()
        name = None
        nop = re.search('op *= *([-0-9]+)', txt)
        if nop:
            name = nop.group(1)
            fmt = 'op%04d.F90'
            if name[0] == '-':
                fmt = 'ops%03d.F90'
                name = name[1:]
            name = fmt % int(name)
        else:
            nop = re.search(r'op *= *OPS *\([\'\"]\w+\.(\w+)\.\w+[\'\"]\)', txt)
            if nop:
                name = nop.group(1)
                print(name)
                name = name+'.py'
            else:
                # for Code_Aster version <= 11.0.0
                nop = re.search(r'op *= *(\w+)', txt)
                if nop:
                    name = nop.group(1) + '.py'
        if name:
            Show(run, name)
        else:
            run.Mess(ufmt(_('op statement not found in %s'), capy), '<A>_ALARM')


def GetOP(run, *list_capy):
    bwc_getop(ShowOP, run, *list_capy)


def Diff(run, *args):
    """Show the diff of a source file.
    """
    kwargs = { 'get' : False, 'diff' : True }
    Get(run, *args, **kwargs)


def Show(run, *args):
    """Show a source file : fortran, c, python, capy, cata, histor or test.
    """
    kwargs = { 'get' : False }
    Get(run, *args, **kwargs)


def Get(run, *args, **kwargs):
    """Copy a source file (as Show) in current directory
    """
    get  = kwargs.get('get',  True)
    diff = kwargs.get('diff', False)

    run.check_version_setting()
    if len(args) < 1:
        run.parser.error(
                _("'--%s' requires one or more arguments") % run.current_action)
    l_file = list(args[:])

    run.PrintExitCode = False
    copy = True
    if run['nolocal'] or diff:
        user, mach = get_devel_param(run)
        REPREF = run.get_version_path(osp.basename(run['aster_vers']), '/aster')
        if not diff:
            # répertoires (en distant on suppose une organisation standard)
            RC    = os.path.join(REPREF, 'bibc')
            RFORT = os.path.join(REPREF, 'bibfor')
            RF90  = os.path.join(REPREF, 'bibf90')
            RPY   = os.path.join(REPREF, 'bibpyt')
            RHIST = os.path.join(REPREF, 'histor')
            RCAPY = os.path.join(REPREF, 'catapy')
            RCATA = os.path.join(REPREF, 'catalo')
            RTEST = os.path.join(REPREF, 'astest')
        else:
            # répertoires stockant les diffs
            RC    = os.path.join(REPREF, 'diffc')
            RFORT = os.path.join(REPREF, 'diffsub')
            RF90  = os.path.join(REPREF, 'diff90')
            RPY   = os.path.join(REPREF, 'diffpyt')
            RHIST = os.path.join(REPREF, 'histor')
            RCAPY = os.path.join(REPREF, 'diffcpyt')
            RCATA = os.path.join(REPREF, 'diffcat')
            RTEST = os.path.join(REPREF, 'diffct')
    else:
        user, mach = run.system.getuser_host()
        REPREF = run.get_version_path(run['aster_vers'])
        # répertoires
        conf = build_config_of_version(run, run['aster_vers'])
        RC    = os.path.join(REPREF, conf['SRCC'][0])
        RFORT = os.path.join(REPREF, conf['SRCFOR'][0])
        RF90  = os.path.join(REPREF, conf['SRCF90'][0])
        RPY   = os.path.join(REPREF, conf['SRCPY'][0])
        RHIST = os.path.join(REPREF, conf['SRCHIST'][0])
        RCAPY = os.path.join(REPREF, conf['SRCCAPY'][0])
        RCATA = os.path.join(REPREF, conf['SRCCATA'][0])
        RTEST = os.path.join(REPREF, conf['SRCTEST'][0])
        RTEST = [osp.join(REPREF, path) for path in conf['SRCTEST']]
        # si 'local' et 'show', pas de copie
        if not get:
            copy = False

    # ----- répertoire temporaire
    if not get:
        rdest = run['cache_dir']
    else:
        rdest = os.getcwd()
    machdest = run.system.getuser_host()[1]

    fmt = '-- %-44s [%+30s]'

    nberr = 0
    seen = set()
    export_dest = ''
    while len(l_file) > 0:
        obj = l_file.pop(0)
        silent = False
        if type(obj) in (list, tuple):
            obj, silent = obj
        toedit = []
        # l'extension fournit le type sauf pour les histor
        if re.search(r'[0-9]+\.[0-9]+\.[0-9]+', obj):
            baseobj = obj
            ext = 'hist'
        else:
            baseobj, ext = os.path.splitext(obj)
            ext = re.sub(r'^\.', '', ext)
        if ext == '':
            silent = True
            l_file.extend([(obj.lower() + '.F90', silent),
                           (obj + '.py', silent),
                           (obj + '.c', silent),
                           (obj.lower() + '.comm', silent),
                           (obj.lower() + '.capy', silent),
                           (obj.lower() + '.cata', silent),
                           ])
            baseobj = baseobj.lower()
            ext = 'F90'
            obj = obj.lower() + '.' + ext
        if ext == 'h':
            l_file.append(baseobj.lower() + '.hf')
        rep = ''
        srep = 0
        ct = 0
        if ext in ('c', 'h'):
            rep = RC
            srep = 1
        elif ext == 'f':
            rep = RFORT
            srep = 1
        elif ext == 'F':
            rep = RF90
            srep = 1
        elif ext == 'F90':
            rep = RFORT
            srep = 1
        elif ext == 'hf':
            ext = 'h'
            rep = RFORT
            srep = 1
        elif ext == 'py':
            rep = RPY
            srep = 1
        elif ext == 'hist':
            rep = RHIST
        elif ext == 'capy':
            rep = RCAPY
            srep = 1
        elif ext == 'cata':
            rep = RCATA
            srep = 1
        elif ext in ('comm', 'mail', 'mmed', 'mess', 'resu', 'para', 'code',
                   'datg', 'msup', 'msh', 'mgib', 'export') \
            or re.search('com[0-9]', ext) != None or ext.isdigit():
            rep = RTEST
            ct = 1
        obj = baseobj + '.' + ext
        lrep = force_list(rep)

        niverr_cp = '<E>_COPY_ERROR'
        if silent:
            niverr_cp = 'SILENT'
        if rep == '':
            print(fmt % (obj, _('type unsupported')))
            nberr += 1
        else:
            with_export = False
            export_file = ''
            for rep in lrep:
                if run['all_test'] and not with_export:
                    with_export = True
                    obj = baseobj + '.export'
                    run.options['all_test'] = False
                    export_dest = rdest = osp.join(rdest, baseobj)
                    if not osp.isdir(rdest):
                        os.mkdir(rdest)
                    export_file = osp.join(rdest, obj)
                if export_dest:
                    rdest = export_dest
                if not silent: print(fmt % (obj, rep))
                run.DBG("search '%s' from '%s'" % (obj, rep))
                jret = 0
                # le fichier existe ou on ne peut pas le vérifier
                if mach != machdest or srep == 1 or \
                    (mach == machdest and glob.glob(osp.join(rep, obj))):
                    # 1. récupérer le(s) fichier(s)
                    if run['all_test'] and ct == 1:
                        # cas-test : all
                        # est-il dans le cache ?
                        if not run['force'] and \
                                os.path.isdir(os.path.join(rdest, baseobj)):
                            if not silent: print('  |  '+_('from cache'))
                            copy = True
                        else:
                            src = os.path.join(rep, baseobj + '.*')
                            if copy:
                                if not os.path.isdir(os.path.join(rdest, baseobj)):
                                    os.mkdir(os.path.join(rdest, baseobj))
                                if mach == machdest:
                                    if not silent: print('  |  '+_('copy all files of the test'))
                                else:
                                    if not silent: print('  |  '+_('remote copy of the test files'))
                                    src = user+'@'+mach+':'+src
                                jret = run.Copy(os.path.join(rdest, baseobj), src, niverr=niverr_cp)
                            else:
                                toedit = glob.glob(src)
                                if not silent: print('  |  '+_('just edit'))
                    else:
                        # fichier individuel
                        # est-il dans le cache ?
                        if not run['force'] and \
                                os.path.isfile(os.path.join(rdest, obj)):
                            if not silent: print('  |  '+_('from cache'))
                            copy = True
                        else:
                            if srep == 1:
                                lsrc = [osp.join(rep, '*', obj),
                                        osp.join(rep, '*', '*', obj),
                                        osp.join(rep, '*', '*', '*', obj)]
                            else:
                                lsrc = [osp.join(rep, obj)]
                            if copy:
                                if mach == machdest:
                                    if not silent: print('  |  '+_('copy'))
                                else:
                                    if not silent: print('  |  '+_('remote copy'))
                                    src = user+'@'+mach+':'+src
                                    lsrc = [user+'@'+mach+':'+src for src in lsrc]
                                for src in lsrc:
                                    jret = run.Copy(rdest, src, niverr=niverr_cp)
                            else:
                                toedit = []
                                for src in lsrc:
                                    toedit.extend(glob.glob(src))
                                if not silent: print('  |  '+_('just edit'))

                    # 2. test / edition
                    if jret != 0:
                        if not silent: print('  |  '+_('error occurs during copying'))
                        nberr += 1
                    else:
                        # si show
                        if not get:
                            if not copy:
                                pass
                            elif run['all_test'] and ct == 1:
                            # cas-test : all
                                if not silent: print('  |  '+_('edit files'))
                                toedit = [os.path.join(rdest, baseobj, '*')]
                            else:
                            # fichier individuel
                                if not silent: print('  |  '+_('edit file'))
                                toedit = [os.path.join(rdest, obj)]
                            toedit = set(toedit).difference(seen)
                            if len(toedit) == 0:
                                run.DBG("search '%s' from '%s' : not found" % (obj, rep))
                                if not silent: run.Mess('', '<E>_FILE_NOT_FOUND')
                            else:
                                s_edit = ' '.join(toedit)
                                seen.update(toedit)
                                edit_file(run, s_edit)
                else:
                    # fichier inexistant
                    run.DBG("search '%s' from '%s' : not found" % (obj, rep))
                    if not silent:
                        print(' |   '+_('file not found'))
                        nberr += 1
                if with_export and osp.isfile(export_file):
                    prof = AsterProfil(export_file)
                    data = prof.get_data()
                    l_file.extend([entry.path for entry in data])

    if nberr > 0:
        if nberr > 1:
            s = 's'
        else:
            s = ''
        run.Mess(_('%(nberr)d error%(s)s detected') % {'nberr' : nberr, 's' : s}, '<A>_ALARM')


def GetVersion(run, *args, **kwargs):
    """Return release number of current development version :
        result[0:3] : version number
        result[3]   : date of release
        result[4]   : True if "exploitation", False if it's a "development" version
    """
    run.check_version_setting()
    if len(args) > 0:
        run.parser.error(_("'--%s' requires no argument") % run.current_action)
    # ----- default keywords
    run.PrintExitCode = False
    silent = False
    vers = run['aster_vers']
    if 'silent' in kwargs:
        silent = kwargs['silent']
    if 'vers' in kwargs:
        vers = kwargs['vers']

    result = get_aster_version(vers)
    iret = 0
    if len(result) != 6:
        iret = 4
    elif not silent:
        if result[4]:
            typv = _('exploitation')
        else:
            typv = _('development')
        run.Mess(_('Version %s %s - %s - %s') \
                 % (typv, '.'.join(result[:3]), result[3], result[5]))
    return iret, result

def GetVersionPath(run, *args, **kargs):
    """Return the path of the default version."""
    run.check_version_setting()
    if len(args) > 0:
        run.parser.error(_("'--%s' requires no argument") % run.current_action)
    run.PrintExitCode = False
    # ----- default keywords
    run.PrintExitCode = False
    vers = run['aster_vers']
    repref = run.get_version_path(vers)
    print(repref)

def get_aster_version(vers, error=True):
    """Return the Code_Aster version named `vers`.
    """
    run = magic.run
    use_waf = False
    conf = build_config_of_version(run, vers, error=False)
    if conf:
        build = AsterBuild(run, conf)
        use_waf = build.support('waf')
        bibpyt = conf.get_with_absolute_path('SRCPY')[0]
        if build.support('container'):
            bibpyt = run.get_version_path(vers)
    else:
        bibpyt = osp.join(run.get_version_path(vers), 'bibpyt')

    # ----- properties.py
    f = os.path.join(bibpyt, 'Accas', 'properties.py')
    if use_waf:
        f = os.path.join(bibpyt, 'aster_pkginfo.py')
    if not os.path.isfile(f):
        if not error:
            return None
        run.Mess(ufmt(_('file not found : %s'), f), '<F>_FILE_NOT_FOUND')
    mydict = {}
    with open(f) as fi:
        exec(compile(fi.read(), f, 'exec'), mydict)
    if use_waf:
        pkg = mydict['version_info']
        rev = 'rev. %s%s' % (pkg[1][:12], '+' if pkg[5] != 0 else '')
        result = list(map(str, pkg[0])) + [pkg[3], pkg[2].startswith('v'), rev]
    else:
        result = mydict['version'].split('.')
        result.append(mydict['date'])
        result.append(mydict.get('exploit', False))
        result.append('rev unknown')
    return result

# for backward compatibility
get_version = partial(bwc_get_version, get_aster_version)


def MakeAster(run, *args):
    """Interface between Makefile and asrun.
    Build Code_Aster from sources, clean object files.
    """
    run.check_version_setting()
    REPREF = run.get_version_path(run['aster_vers'])
    fconf = run.get('config')
    if fconf:
        fconf = osp.abspath(fconf)
    conf = build_config_of_version(run, run['aster_vers'], fconf)

    # check arguments
    target = 'all'
    param  = []
    if len(args) > 0:
        target = args[0]
        param = args[1:]

    run.PrintExitCode = False
    # set per version environment
    for f in conf.get_with_absolute_path('ENV_SH'):
        run.AddToEnv(f)

    run.print_timer = True

    # 0. ----- working directory during build
    reptrav = get_tmpname(run, basename='build')
    run.ToDelete(reptrav)
    run.MkDir(reptrav)

    # 1. ----- Go !
    if target == 'all':
        run.ExitOnFatalError = False
        mail = []
        try:
            _build_aster(run, conf, False, REPREF, run.get('destdir'), reptrav)
        except RunAsterError as msg:
            run.ExitOnFatalError = True
            mail.extend([_('Exception raised by MakeAster:'),
                '-'*60, _('Traceback:')])
            mail.append(traceback.format_exc())
            mail.append('-'*60)
            mail.append(_('Exit code : %s') % msg)
            errmsg = os.linesep.join(mail)
            mail.append(run.get_important_messages(reinit=True))
            if run['report_to'] != '':
                subject = 'Built of %s failed on %s' % \
                        (run.get_version_path(run['aster_vers']), local_host)
            run.Mess(errmsg, '<F>_BUILD_FAILED')
        else:
            subject = ufmt(_('Built of %s ended successfully on %s'),
                           run.get_version_path(run['aster_vers']), local_host)
            mail.append(subject)
            run.ExitOnFatalError = True
            run.Mess(os.linesep.join(mail), 'OK')
        if run['report_to'] != '':
            run.SendMail(dest=run['report_to'],
                text = os.linesep.join(mail),
                subject = subject)

    elif target == 'clean':
        if len(param) == 0:
            l_clean = ['BIN_NODBG', 'BIN_DBG', 'BINCMDE', 'BINCMDE_ZIP', 'BINELE', 'BINPICKLED',
                    'BINLIB_NODBG', 'BINLIB_DBG', 'BINSHLIB_NODBG', 'BINSHLIB_DBG',
                    'BINLIBF_NODBG', 'BINLIBF_DBG', 'BINSHLIBF_NODBG', 'BINSHLIBF_DBG',
                    'BINOBJ_NODBG', 'BINOBJF_NODBG', 'BINOBJ_DBG', 'BINOBJF_DBG']
            for key in l_clean:
                ficrep = os.path.join(REPREF, conf[key][0])
                if conf[key][0] != '':
                    run.Delete(ficrep, verbose=True)
                remove_empty_dirs(REPREF)
        else:
            for dsrc in param:
                # source files
                lf = []
                for ext in ('*.c', '*.f', '*.F'):
                    lf.extend(glob.glob(os.path.join(REPREF, dsrc, ext)))
                # object files
                lo = [os.path.splitext(os.path.basename(f))[0]+'.o' for f in lf]
                for dobj in ('BINOBJ_NODBG', 'BINOBJ_DBG'):
                    ficrep = conf[dobj][0]
                    if ficrep != '':
                        run.VerbStart(ufmt(_('remove %d object files of %s from %s'), len(lo),
                                      dsrc, ficrep), verbose=True)
                        for fo in lo:
                            run.Delete(os.path.join(REPREF, ficrep, fo))
                        run.VerbEnd(0, '%5d files' % len(lo), verbose=True)
    else:
        run.Mess(_('unknown target : %s') % target, '<F>_INVALID_ARGUMENT')


def _build_aster(run, conf, iupdate, REPREF, destdir, reptrav, lardv=None):
    """Build or update Aster depending of iupdate value.
        iupdate : False for 'make', True for 'update'
        lardv   : list of object files to remove from lib_aster
    """
    if lardv == None:
        lardv = []
    build = AsterBuild(run, conf)
    DbgPara = {
        'debug'     : { 'exe'    : conf['BIN_DBG'][0],
                      'suff'   : conf['BINOBJ_DBG'][0],
                      'suffer' : conf['BINOBJF_DBG'][0],
                      'libast' : conf['BINLIB_DBG'][0],
                      'libfer' : conf['BINLIBF_DBG'][0]},
        'nodebug'   : { 'exe'    : conf['BIN_NODBG'][0],
                      'suff'   : conf['BINOBJ_NODBG'][0],
                      'suffer' : conf['BINOBJF_NODBG'][0],
                      'libast' : conf['BINLIB_NODBG'][0],
                      'libfer' : conf['BINLIBF_NODBG'][0]},
    }
    debug_mode = [mod for mod in conf['MAKE'][0].split() if mod in ('debug', 'nodebug')]
    if not destdir:
        destdir = REPREF

    # ----- Initialize Runner object
    runner = Runner(conf.get_defines())
    runner.set_cpuinfo(1, 1)
    reptrav = runner.set_rep_trav(reptrav)

    # 1a. ----- perform update twice : debug and nodebug modes
    # first, remove object files from libaster
    if iupdate:
        for mode in debug_mode:
            libaster = os.path.join(destdir, DbgPara[mode]['libast'])
            # for backward compatibility
            if run.IsDir(libaster):
                libaster = os.path.join(libaster, 'lib_aster.lib')
            run.Mess(_('Start build in %s mode') % mode, 'TITLE')

            tit = _('Deletion of old files')
            run.timer.Start(tit)
            # 'ar -dv' not provided in config.txt
            cmd = [conf['LIB'][0].split()[0], '-dv', libaster]
            cmd.extend(lardv)
            run.VerbStart(ufmt(_('remove object files from %s'), os.path.basename(libaster)),
                verbose=True)
            if lardv:
                if run['verbose']:
                    print()
                kret, out = run.Shell(' '.join(cmd))
                # ----- avoid to duplicate output
                if not run['verbose']:
                    run.VerbEnd(kret, output=out, verbose=True)
                if kret != 0:
                    run.Mess(_('error during deleting objects from archive'),
                            '<A>_ARCHIVE_ERROR')
            else:
                run.VerbIgnore(verbose=True)
            run.timer.Stop(tit)
            run.CheckOK()

    # 1b. ----- perform update twice : debug and nodebug modes
    for mode in debug_mode:
        libaster = os.path.join(destdir, DbgPara[mode]['libast'])
        libferm  = os.path.join(destdir, DbgPara[mode]['libfer'])
        # for backward compatibility
        if run.IsDir(libaster):
            libaster = os.path.join(libaster, 'lib_aster.lib')
        if run.IsDir(libferm):
            libferm = os.path.join(libaster, 'ferm.lib')
        run.Mess(_('Start build in %s mode') % mode, 'TITLE')

        # 1.2. compile updated files
        tit = _('Compilation in %s mode') % mode
        run.timer.Start(tit)
        kret = build.CompilAster(REPREF, dbg=mode)
        run.timer.Stop(tit)
        run.CheckOK()

        # 1.3. archive '.o'
        # 1.3.1. obj or dbg
        tit = _('Add object files to library')
        run.timer.Start(tit)
        kret = build.Archive(repobj=os.path.join(REPREF, DbgPara[mode]['suff']),
                lib=libaster)
        run.CheckOK()

        # 1.3.2. obj_f or dbg_f
        kret = build.Archive(
                repobj=os.path.join(REPREF, DbgPara[mode]['suffer']),
                lib=libferm)
        run.CheckOK()
        run.timer.Stop(tit)

        # 1.4. update executable
        exec_name = os.path.join(destdir, DbgPara[mode]['exe'])
        # 1.4.1. build
        tit = _('Build executables')
        run.timer.Start(tit)
        kret = build.Link(exec_name, [], libaster, libferm, reptrav)
        run.timer.Stop(tit)
        run.CheckOK()

        # 1.4.2. testing binary
        # - executable is callable (no shared library unreferenced)
        # - required Python modules are present
        tit = _('Test executables')
        run.timer.Start(tit)
        cmd = exec_name + ' -c '
        cpyt = ['import traceback']
        cmd_import = """
print '%(cmd)s :',
try:
    %(cmd)s
    print 'OK'
except:
    print 'FAILED'
"""
        cpyt.append(cmd_import % {'cmd' : 'import os'})
        cpyt.append(cmd_import % {'cmd' : 'import aster'})
        run.VerbStart(ufmt(_('testing executable %s...'), exec_name), verbose=True)
        if run['verbose']:
            print()
        cmd_exec = runner.get_exec_command('%s "%s"' % (cmd, ''.join(cpyt)),
            env=conf.get_with_absolute_path('ENV_SH'))
        kret, out = run.Shell(cmd_exec)
        # ----- avoid to duplicate output
        expr = re.compile('(^.*FAILED.*$)', re.MULTILINE)
        l_err = expr.findall(out)
        kret = max(kret, len(l_err))
        if not run['verbose']:
            run.VerbEnd(kret, output=out, verbose=True)
        if kret != 0:
            run.Mess(_('test of executables failed'), '<F>_BUILD_FAILED')
        run.timer.Stop(tit)

    # 2. ----- compile commands
    kargs = {
        'exe'    : os.path.join(destdir, DbgPara['nodebug']['exe']),
        'cmde'   : os.path.join(destdir, conf['BINCMDE'][0]),
    }
    if not run.Exists(kargs['exe']):
        kargs['exe'] = os.path.join(destdir, DbgPara['debug']['exe'])
    tit = _('Compilation of commands catalogue')
    run.timer.Start(tit)
    kret = build.CompilCapy(REPREF, reptrav, i18n=True, **kargs)
    run.timer.Stop(tit)
    run.CheckOK()

    # 3. ----- compile elements
    kargs.update({
        'ele'    : os.path.join(destdir, conf['BINELE'][0]),
        'pickled' : os.path.join(destdir, conf['BINPICKLED'][0]),
    })
    tit = _('Make pickled of elements')
    run.timer.Start(tit)
    kret = build.MakePickled(REPREF, reptrav, repdest=destdir, **kargs)
    run.timer.Stop(tit)
    run.CheckOK()

    tit = _('Elements compilation')
    run.timer.Start(tit)
    kret = build.CompilEle(REPREF, reptrav, **kargs)
    run.timer.Stop(tit)
    run.CheckOK()

    # 4. ----- copy of auxiliary files
    if os.path.abspath(destdir) != os.path.abspath(REPREF):
        lsrc = [os.path.join(REPREF, fsrc) for fsrc in [conf['SRCPY'][0], conf.get_filename()]]
        run.Copy(destdir, *lsrc)
        #XXX only works if the files are in REPREF
        lsrc = [os.path.join(REPREF, fsrc) for fsrc in conf['ENV_SH'] \
                if fsrc == os.path.basename(fsrc)]
        run.Copy(destdir, *lsrc)

    # 9. ----- end
    run.Mess(_('Code_Aster has been successfully built'), 'OK')


def Update(run, *args, **kwargs):
    """Extract "aster-maj" archives and make the update
    kwargs['num_update'] allow to have separate 'reptrav' for successive updates.
    """
    run.check_version_setting()
    REPREF = run.get_version_path(run['aster_vers'])
    fconf = run.get('config')
    if fconf:
        fconf = osp.abspath(fconf)
    conf = build_config_of_version(run, run['aster_vers'], fconf)
    build  = AsterBuild(run, conf)

    # check arguments
    if len(args) < 1:
        run.parser.error(
                _("'--%s' requires one or more arguments") % run.current_action)

    # id
    num_update = kwargs.get('num_update', 1)

    run.PrintExitCode = False
    # set per version environment
    for f in conf.get_with_absolute_path('ENV_SH'):
        run.AddToEnv(f)

    run.print_timer = True
    larch = []
    for arch in args:
        larch.append(os.path.abspath(arch))

    # 0. ----- working directory during update(s)
    reptrav       = get_tmpname(run, basename='update.num%s' % num_update)
    reptrav_built = get_tmpname(run, basename='update_built.num%s' % num_update)
    run.ToDelete(reptrav)
    run.ToDelete(reptrav_built)
    run.MkDir(reptrav)
    run.MkDir(reptrav_built)
    prefix = 'maj'
    repmaj = os.path.join(reptrav, prefix)
    run.ToDelete(repmaj)
    run.MkDir(repmaj)

    tit = _('Extraction of archives')
    run.timer.Start(tit)
    # 1. ----- for each archive
    os.chdir(reptrav)
    funig = os.path.join(repmaj, 'unigest')
    lupd  = set()
    lunig = set()
    for arch in larch:
        arch = os.path.abspath(arch)
        if tarfile.is_tarfile(arch):
            linfo = []

            # 1.1. ----- extraction
            run.VerbStart(ufmt(_('extract archive %s'), arch), verbose=True)
            jret = 0
            try:
                tar = tarfile.open(arch, 'r')
                tar.errorlevel = 2
                for ti in tar:
                    tar.extract(ti)
                    # if name is in a previous unigest don't delete it
                    name = re.sub('^'+prefix+'/', '', ti.name)
                    if os.path.basename(name) != '' and name != 'unigest':
                        lupd.add(name)
                    if name in lunig:
                        linfo.append(name)
                        lunig.remove(name)
            except tarfile.ExtractError:
                jret = 4
            run.VerbEnd(jret, verbose=True)
            tar.close()
            if jret != 0:
                run.Mess(ufmt(_('error during extracting archive %s'), arch), '<F>_TAR_ERROR')

            # 1.2. ----- give info about files not to delete
            if linfo:
                run.Mess(_('These files should have previously been deleted ' \
                        'and now they are updated :'))
                print(', '.join(linfo))

            # 1.3. ----- get directives from unigest
            linfo = []
            if os.path.exists(funig):
                for k, val in list(build.GetUnigest(funig).items()):
                    if k == 'fdepl':
                        lunig.update([i[0] for i in val])
                    elif k != 'filename':
                        lunig.update(val)
                os.remove(funig)
                # delete files from maj which have been modified since last update
                for path in lunig:
                    lf = glob.glob(os.path.join(repmaj, path))
                    if len(lf) > 0:
                        for i in lf:
                            lupd.discard(f)
                        linfo.extend(lf)

            # 1.4. ----- give info about files to delete before update
            if linfo:
                run.Mess(_('These files have been modified by a previous update ' \
                        'but now they are deleted :'))
                for f in linfo:
                    run.Delete(f, verbose=True)

        else:
            run.Mess(ufmt(_('invalid tar (compressed) archive or ' \
                    'file not found : %s'), arch), '<F>_FILE_NOT_FOUND')
    run.timer.Stop(tit)

    # 2. ----- start update
    # current version
    i, vvv = GetVersion(run, silent=True, vers=run['aster_vers'])
    if i != 0:
        run.Mess(_('error occurs during getting release number'), '<F>_ERROR')
    old_vers = '.'.join(vvv[:3])
    # target version
    i, vnext = GetVersion(run, silent=True, vers=repmaj)
    if i != 0:
        run.Mess(_('error occurs during getting release number'), '<F>_ERROR')
    new_vers = '.'.join(vnext[:3])
    run.Mess(_('Update version %s to %s') % (old_vers, new_vers), 'TITLE')

    # 3. ----- copy files
    tit = _('Copy of updated files')
    run.timer.Start(tit)
    run.Mess(_('Copy updated files'), 'TITLE')
    os.chdir(repmaj)
    fmt_copy = '| %s'
    ddirs = {
        conf['SRCFOR'][0]  : ['bibfor',   ('*.f', '*.h')],
        conf['SRCF90'][0]  : ['bibf90',   ('*.f', '*.F', '*.h')],
        conf['SRCC'][0]    : ['bibc',     ('*.c', '*.h')],
        conf['SRCPY'][0]   : ['bibpyt',   '*.py'],
        conf['SRCCAPY'][0] : ['catapy',   '*.capy'],
        conf['SRCCATA'][0] : ['catalo',   '*.cata'],
        conf['SRCFERM'][0] : ['fermetur', '*.f'],
        conf['SRCTEST'][0] : ['test',     '*'],
        conf['SRCHIST'][0] : ['regexp',   r'^[0-9]+\.[0-9]+\.[0-9]+$'],
    }
    for repdest, param in list(ddirs.items()):
        if repdest == '':
            run.VerbStart(_('updating %s') % (param[0]), verbose=True)
            run.VerbIgnore(verbose=True)
            continue
        rep  = param[0]
        l_suff = param[1]
        if not type(l_suff) in (list, tuple):
            l_suff = [l_suff,]
        for suff in l_suff:
            if rep == 'regexp':
                # files by regular expression
                expr = re.compile(suff)
                l_files = [f for f in os.listdir('.') if expr.search(f)]
                run.DBG('histor files :', os.listdir('.'), l_files)
                dest = os.path.join(REPREF, repdest)
                run.VerbStart(_('updating %s') % dest, verbose=True)
                run.MkDir(dest, verbose=False)
                if len(l_files) > 0:
                    jret = run.Copy(dest, *l_files)
                    run.VerbEnd(jret, verbose=True)
                else:
                    run.VerbIgnore(verbose=True)
            elif os.path.isdir(rep):
                ldirs = glob.glob(os.path.join(rep, '*/'))
                # for test and fermetur files are not in a subdirectory
                if rep in ('test', 'fermetur'):
                    ldirs = [rep,] + ldirs
                for entry in ldirs:
                    src = os.path.join(entry, suff)
                    # rep/* or rep/sub/* ?
                    if len(src.split(os.sep)) == 2:
                        dest = os.path.join(REPREF, repdest)
                    else:
                        subdir = os.path.basename(os.path.normpath(entry))
                        dest = os.path.join(REPREF, repdest, subdir)
                    run.VerbStart(_('updating %s (%s)') % (dest, suff), verbose=True)
                    run.MkDir(dest, verbose=False)
                    if len(glob.glob(src)) == 0:
                        run.VerbIgnore(verbose=True)
                    else:
                        jret = run.Copy(dest, src)
                        run.VerbEnd(jret, verbose=True)
                        for fsrc in glob.glob(src):
                            run.Mess(fmt_copy % os.path.join(dest, os.path.basename(fsrc)),
                            'SILENT')

    run.timer.Stop(tit)

    # 4. ----- delete source files
    tit = _('Deletion of old files')
    run.timer.Start(tit)
    run.Mess(_('Apply unigest directives'), 'TITLE')
    lardv = []
    for f in lunig:
        run.Delete(os.path.join(REPREF, f), verbose=True)
        if re.search('^'+conf['SRCC'][0]+'/' + \
                        '|^'+conf['SRCFOR'][0]+'/' + \
                        '|^'+conf['SRCF90'][0]+'/', f):
            lardv.append(os.path.basename(re.sub(r'\.[cfF]+$', '.o', f)))
    run.timer.Stop(tit)

    # 5. ----- update executable, libs and catalogues
    _build_aster(run, conf, True, REPREF, None, reptrav_built, lardv=lardv)
    run.Delete(reptrav)
    run.Delete(reptrav_built)


def AutoUpdate(run, *args):
    """Try to download available updates and apply them.
    """
    run.parser.error(_("'--%s' is not supported anymore, see "
        "https://bitbucket.org/code_aster/codeaster-src/wiki/Quickstart") % run.current_action)


def MakeDiag(run, *args):
    """Build the diagnosis of execution of testcases
    """
    # check arguments
    run.check_version_setting()
    if len(args) > 1:
        run.parser.error(_("'--%s' requires at most one argument") % run.current_action)
    l_dirs = run.get('astest_dir')
    if not l_dirs:
        run.parser.error(_("'--astest_dir' option is required"))

    REPREF = run.get_version_path(run['aster_vers'])
    run.PrintExitCode = False
    run.print_timer = False
    fconf = run.get('config')
    if fconf:
        fconf = osp.abspath(fconf)
    conf = build_config_of_version(run, run['aster_vers'], fconf)
    build  = AsterBuild(run, conf)

    # 0. ----- initializations
    fmt_header = _("""
--- Directory of testcases files    : %(s_astest_dir)s
    Version                         : %(version)s
    Number of test-cases            : %(nbtest)s
    Number of errors                : %(err_all)s
""")
    fmt_lign = '%(test)-12s %(diag)-18s %(tcpu)10.2f %(tsys)10.2f %(ttot)10.2f %(diffvers)8s'
    fmt_tot  = '-'*12 + ' ' + '-'*18 + ' ' + '-'*10 + ' ' + '-'*10 + ' ' + '-'*10

    # 1. ----- Go !
    l_dirs = [os.path.join(REPREF, os.path.abspath(p.strip())) \
            for p in l_dirs.split(',')]
    # testcases list
    if not run.get('test_list'):
        list_tests = set()
        for p in l_dirs:
            list_tests.update([os.path.splitext(f)[0] for f in glob.glob1(p, '*.comm')])
            list_tests.update([os.path.splitext(f)[0] for f in glob.glob1(p, '*.mess')])
        list_tests = list(list_tests)
    else:
        flist = run['test_list']
        iret, list_tests = get_list(flist)
        if iret != 0:
            run.Mess(ufmt(_('error during reading file : %s'), flist), '<F>_ERROR')

    # get the dict result
    dict_resu = getDiagnostic(run, build, l_dirs, list_tests)
    vlast = dict_resu['__global__']['version']
    nbtest = len(list_tests)

    t = [0., 0., 0.]
    nbnook = 0
    noresu = 0
    l_txt = []

    for test in list_tests:
        t[0] += dict_resu[test]['tcpu']
        t[1] += dict_resu[test]['tsys']
        t[2] += dict_resu[test]['ttot']
        diag = dict_resu[test]['diag']
        vers = dict_resu[test]['vers']
        if vers != vlast:
            dict_resu[test]['diffvers'] = vers or '?'
        else:
            dict_resu[test]['diffvers'] = ''
        # count nook
        if run.GetGrav(diag) >= run.GetGrav('NOOK'):
            nbnook += 1
        # count test without .resu
        if dict_resu[test]['vers'] == '':
            noresu += 1
        if run.GetGrav(diag) >= run.GetGrav('NOOK') \
                or not run['only_nook'] or vers != vlast:
            l_txt.append( fmt_lign % dict_resu[test] )

    l_txt.append( fmt_tot )
    l_txt.append( fmt_lign % {
            'test' : _('%4d tests') % nbtest,
            'diag' : _('%d errors') % nbnook,
            'tcpu' : t[0],
            'tsys' : t[1],
            'ttot' : t[2],
            'diffvers' : '',
        })
    l_txt.append('')

    dict_resu['__global__']['err_all']    = nbnook

    print(fmt_header % dict_resu['__global__'])
    print(os.linesep.join(l_txt))

    # write dict_resu to diag.pick
    if len(args) > 0:
        fpick = args[0]
    else:
        fpick = 'diag.pick'
    fpick = os.path.join(REPREF, fpick)
    parent = os.path.normpath(os.path.join(fpick, os.pardir))
    if os.access(parent, os.W_OK):
        with open(fpick, 'wb') as pick:
            pickle.dump(dict_resu, pick)
        run.Mess(ufmt(_("Diagnostic dict written into '%s'."), fpick))


def get_diagnostic(run, build, test_dirs, list_tests):
    """Return the diagnosis of the execution of a list of testcases
    """
    warn("'get_diagnostic(run, build, test_dirs, list_tests)' is deprecated " \
         "and replaced by 'getDiagnostic(run, build, test_dirs, list_tests)'.",
         DeprecationWarning, stacklevel=2)
    return getDiagnostic(run, build, test_dirs, list_tests)


def getDiagnostic(run, build, test_dirs, list_tests):
    """Return the diagnosis of the execution of a list of testcases
    """
    list_tests.sort()
    nbtest = len(list_tests)

    # result dict which will be pickled (if we have sufficient permission)
    dict_resu = {
        '__global__' : {
            'astest_dir' : test_dirs,
            's_astest_dir' : ', '.join(test_dirs),
            'nbtest'     : nbtest,
            'err_all'    : 0,
            'err_noresu' : 0,
            'err_vers'   : 0,
        }
    }

    waf_noresu = build.support('noresu')
    ext = '.mess' if waf_noresu else '.resu'
    lastv = ''
    for test in list_tests:
        # search the last resu file
        fresu = ''
        ferre = ''
        fmess = ''
        v_i = ''
        for p in test_dirs:
            vtmp = get_vers(os.path.join(p, test + ext), run['verbose'])
            vtmp = repr_vers(vtmp, '%02d')
            if vtmp > v_i:
                v_i = vtmp
                fresu = os.path.join(p, test + '.resu')
                ferre = os.path.join(p, test + '.erre')
                fmess = os.path.join(p, test + '.mess')
                if not waf_noresu:
                    v_erre = get_vers(ferre, run['verbose'])
                    if v_erre != '' and v_erre != v_i:
                        ferre = ''
        if lastv == '' or v_i > lastv:
            lastv = v_i
        if waf_noresu:
            fresu = ferre = fmess
        run.DBG('Fichiers resu : %s' % fresu, 'Version : %s' % lastv)
        diag, tcpu, tsys, ttot = build.getDiag(err=ferre, resu=fresu,
                                               mess=fmess, cas_test=True)[:4]
        dict_resu[test] = {
            'test'  : test,
            'diag'  : diag,
            'tcpu'  : tcpu,
            'tsys'  : tsys,
            'ttot'  : ttot,
            'vers'  : repr_vers(v_i),
        }

    vlast = repr_vers(lastv)
    dict_resu['__global__']['version']    = vlast
    return dict_resu


def GenCtags(run, force=False):
    """Generate the ctags file.
    """
    run.Mess(_('Generation of ctags database'), 'TITLE')
    run.check_version_setting()
    REPREF = run.get_version_path(run['aster_vers'])

    ctags = run.Which('ctags')
    ftags = 'tags'
    if ctags is None:
        run.Mess(_("'ctags' is not in your PATH. ctags not generated."))
        return

    style = run.get('ctags_style', '')
    if style == 'exuberant':
        # command line for Exuberant Ctags
        cmd = "find %(rep)s -name '%(suff)s' | %(ctags)s -a -o %(ftags)s -L -"
    elif style == 'emacs':
        # command line for GNU Emacs ctags
        cmd = "find %(rep)s -name '%(suff)s' | %(ctags)s -a -o %(ftags)s -"
    else:
        run.Mess(_("'Exuberant Ctags' and 'GNU Emacs ctags' styles are supported. "\
                 "You must define 'ctags_style' in the config file to generate ctags."))
        return

    dcmd = { 'ctags' : ctags, 'ftags' : ftags }
    if not os.access(REPREF, os.W_OK):
        run.Mess(ufmt(_('no write access to %s'), REPREF), '<F>_ERROR')

    prev = os.getcwd()
    os.chdir(REPREF)

    force = run['force'] or force or (not os.path.isfile(ftags))
    if force:
        run.Delete(ftags, verbose=True)
        for rep, suff in (('bibc', '*.c'),
                                ('bibfor', '*.f'),
                                ('bibf90', '*.F'),
                                ('bibpyt', '*.py'),):
            dcmd['rep']  = rep
            dcmd['suff'] = suff
            run.VerbStart(ufmt(_('build ctags file using source from %s'), rep), verbose=True)
            if run['verbose']:
                print()
            iret, out = run.Shell(cmd % dcmd)
            if not run['verbose']:
                run.VerbEnd(iret, output=out, verbose=True)
            if iret != 0:
                run.Mess(_('error during generating ctags'),'<E>_CTAGS_ERROR')
        run.CheckOK()
    else:
        run.Mess(_("ctags file already exists, use --force to overwrite it."))

    os.chdir(prev)


def get_export(run, testcase, resutest=None):
    """Return the AsterProfil object to run a testcase"""
    REPREF = run.get_version_path(run['aster_vers'])
    run.PrintExitCode = False
    conf = build_config_of_version(run, run['aster_vers'])
    prof = build_test_export(run, conf, REPREF,
                             reptest=[], test=testcase, resutest=resutest)
    return prof

def GetExport(run, *args):
    """Build an export file to run a testcase and print it to stdout.
    """
    # ----- check argument
    run.check_version_setting()
    if len(args) != 1:
        run.parser.error(_("'--%s' requires one argument") % run.current_action)
    prof = get_export(run, args[0])
    print(prof.get_content())


def get_vers(fich, debug=False):
    """Extract the version which produced the given file.
    """
    vers = ''
    exp = re.compile(r'Version.* ([0-9]+\.[0-9\.]+) ', re.M | re.I)
    if os.path.isfile(fich):
        with open(fich, 'rb') as f:
            content = f.read().decode(errors='replace')
            l_v = exp.findall(content)
        if len(l_v) > 0:
            vers = l_v[0]
        if debug and vers == '':
            print(ufmt(_('unable to extract version from %s'), fich))
    return vers

def ShowMe(run, *args):
    """Print information about the installation (as --showme of compilers)"""
    from asrun.installation import aster_root, confdir, datadir, localedir
    from asrun.common.utils import get_absolute_dirname
    from asrun.common.sysutils import get_home_directory
    run.PrintExitCode = False
    if len(args) < 1:
        run.parser.error(_("'--%s' requires at leat one argument") % run.current_action)
    what = args[0]
    if what in ('bin', 'lib', 'etc', 'data', 'locale') and len(args) != 1:
        run.parser.error(_("'--%s %s' requires one argument") \
                         % (run.current_action, what))
    if what in ('param', ) and len(args) != 2:
        run.parser.error(_("'--%s %s' requires two arguments") \
                         % (run.current_action, what))
    if what == 'bin':
        print(aster_root)
    elif what == 'lib':
        print(osp.normpath(osp.join(get_absolute_dirname(__file__), os.pardir)))
    elif what == 'etc':
        print(confdir)
    elif what == 'rcdir':
        print(osp.join(get_home_directory(), run.rcdir))
    elif what == 'data':
        print(datadir)
    elif what == 'locale':
        print(localedir)
    elif what == 'param':
        value = run.get(args[1], "")
        print(value)
    else:
        pass

def repr_vers(vers, fmt='%d'):
    """Return a representation of `vers` like '8.3.11' or '08.03.11' using `fmt`.
    """
    if vers == '':
        return vers
    l_v = vers.split('.')
    l_v = l_v + ['0'] * (3 - len(l_v))
    l_out = []
    for i in l_v:
        if not i.isdigit():
            l_out.append(i)
        else:
            l_out.append(fmt % int(i))
    return '.'.join(l_out)
