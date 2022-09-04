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
Give functions :
- to compile code source, to create catalogue and to build
an executable file,
- to execute Code_Aster...
Functions are called by an AsterRun object.
"""

import os
import os.path as osp
from glob import glob

from asrun.core         import magic
from asrun.common.i18n  import _
from asrun.mystring     import ufmt
from asrun.profil       import AsterProfil
from asrun.build        import AsterBuild
from asrun.config       import build_config_from_export
from asrun.maintenance  import get_aster_version, get_export
from asrun.execution    import execute, copyfiles, build_export_from_files, add_all_results
from asrun.runner       import Runner
from asrun.astout       import RunAstout
from asrun.parametric   import Parametric
from asrun.multiple     import Multiple
from asrun.common_func  import get_tmpname
from asrun.common.utils import get_absolute_path, listsurcharge, get_plugin, \
                               NO_VALUES
from asrun.toolbox      import MakeShared


def SetParser(run):
    """Configure the command-line parser, add options name to store to the list,
    set actions informations.
    run : AsterRun object which manages the execution
    """
    acts_descr = {
        'run'       : {
            'method' : RunAster,
            'syntax' : '[options] profile',
            'help'   : _('Execute the execution described by the profile (default action)')
        },
        'quick'     : {
            'method' : StartNow,
            'syntax' : '[options] file1 [file2 [...]] [--surch_pyt=...] [--surch_fort=...]',
            'help'   : _('Start quickly an interactive execution using the files given in arguments')
        },
        'test'     : {
            'method' : StartTestNow,
            'syntax' : '[options] testcase [results_directory]',
            'help'   : _('Start an interactive execution of a testcase')
        },
        'make_shared' : {
            'method' : MakeShared,
            'syntax' : '--output=FILE [src1 [...]] srcN',
            'help'   : _('Produce a shared library named FILE by compiling the '
                'source files src1... srcN. Typically used to build a UMAT library.'),
        },
    }
    opts_descr = {
        'copy_all_results' : {
            'args'   : ('--copy_all_results', ),
            'kwargs' : {
                'action'  : 'store_true',
                'default' : False,
                'dest'    : 'copy_all_results',
                'help'    : _('copy all results in the current directory (for --quick action)')
            }
        },
        'debugger' : {
            'args'   : ('--debugger', ),
            'kwargs' : {
                'action'  : 'store_true',
                'default' : False,
                'dest'    : 'debugger',
                'help'    : _('run in the debugger (for --quick/--test action)')
            }
        },
        'exectool' : {
            'args'   : ('--exectool', ),
            'kwargs' : {
                'action'  : 'store',
                'default' : False,
                'dest'    : 'exectool',
                'help'    : _('run using the specified tool (for --quick/--test action)')
            }
        },
        'run_params' : {
            'args'   : ('--run_params', ),
            'kwargs' : {
                'action'  : 'append',
                'default' : [],
                'dest'    : 'run_params',
                'help'    : _('list of parameters added in the export file '
                               '(for --quick/--test action). '
                               'Example: --run_params=actions=make_env will set "P actions make_env"'
                               ' in the export file')
            }
        },
    }
    run.SetActions(
            actions_descr = acts_descr,
            actions_order = ['run', 'quick', 'test', 'make_shared'],
            group_options = False,
            options_descr=opts_descr
    )


def RunAster(run, *args):
    """Allow to run Code_Aster with or without compiling additional source files,
    check a development, run a list of test cases...
    """
    run.print_timer = True

    prev = os.getcwd()
    # ----- check argument
    if len(args) != 1:
        run.parser.error(_("'--%s' requires one argument") % run.current_action)

    # 1. ----- initializations
    jn = run['num_job']
    fprof = get_tmpname(run, run['tmp_user'], basename='profil_astk')
    run.ToDelete(fprof)

    # 1.1. ----- check argument type
    # 1.1.1. ----- use profile from args
    if isinstance(args[0], AsterProfil):
        prof = args[0].copy()
        prof.WriteExportTo(fprof)
        forig = fprof
    else:
        # 1.1.2. ----- read profile from args
        forig = args[0]
        kret = run.Copy(fprof, forig, niverr='<F>_PROFILE_COPY')
        prof = AsterProfil(fprof, run)
        if not run.IsRemote(forig):
            export_fname = run.PathOnly(get_absolute_path(forig))
            prof.absolutize_filename(export_fname)
    if not prof['mode'][0] in ('batch', 'interactif'):
        run.Mess(_("Unknown mode (%s), use 'interactif' instead") % \
                repr(prof['mode'][0]), 'UNEXPECTED_VALUE')
        prof['mode'] = ['interactif']
    run.DBG("Input export : %s" % fprof, prof)

    # 1.2. get AsterConfig and AsterBuild objects
    REPREF = prof.get_version_path()
    conf = build_config_from_export(run, prof)
    build = AsterBuild(run, conf)
    DbgPara = {
        'debug'     : { 'exe'    : conf['BIN_DBG'][0],
                      'suff'   : conf['BINOBJ_DBG'][0],
                      'libast' : conf['BINLIB_DBG'][0],
                      'libfer' : conf['BINLIBF_DBG'][0]},
        'nodebug'   : { 'exe'    : conf['BIN_NODBG'][0],
                      'suff'   : conf['BINOBJ_NODBG'][0],
                      'libast' : conf['BINLIB_NODBG'][0],
                      'libfer' : conf['BINLIBF_NODBG'][0]},
    }

    # 1.3. set environment depending on version
    for f in conf.get_with_absolute_path('ENV_SH'):
        run.AddToEnv(f)

    # 1.4. set runner parameters
    klass = Runner
    # allow to customize of the execution objects
    if run.get('schema_execute'):
        schem = get_plugin(run['schema_execute'])
        run.DBG("calling plugin : %s" % run['schema_execute'])
        klass = schem(prof)

    runner = klass(conf.get_defines())
    iret = runner.set_cpuinfo(prof['mpi_nbnoeud'][0], prof['mpi_nbcpu'][0])
    if iret == 1:
        run.Mess(ufmt(_("%s is not a MPI version of Code_Aster. "
            "The number of nodes/processors must be equal to 1."), REPREF),
            "<F>_INVALID_PARAMETER")
    elif iret != 0:
        run.Mess(_("incorrect value for mpi_nbnoeud (%s) or mpi_nbcpu (%s)") \
            % (prof['mpi_nbnoeud'][0], prof['mpi_nbcpu'][0]), '<F>_INVALID_PARAMETER')

    # 1.5. rep_trav from profile or from run[...]
    reptrav = runner.set_rep_trav(prof['rep_trav'][0], prof['mode'][0])

    # write reptrav in the export
    prof['rep_trav'] = reptrav
    prof.WriteExportTo(prof.get_filename())
    #XXX overrides the original export
    if forig != prof.get_filename():
        run.Copy(forig, prof.get_filename(), niverr='<A>_ALARM')

    # add reptrav to LD_LIBRARY_PATH (to find dynamic libs provided by user)
    old = os.environ.get("LD_LIBRARY_PATH", "")
    os.environ["LD_LIBRARY_PATH"] = (reptrav + os.pathsep + old).strip(os.pathsep)

    # do not reinitialize rep_trav if
    if prof['prep_env'][0] not in NO_VALUES:
        run.MkDir(reptrav, chmod=0o700)
    if prof['detr_rep_trav'][0] not in NO_VALUES:
        run.ToDelete(reptrav)

    # 1.6. copy profile in rep_trav
    kret = run.Copy(osp.join(reptrav, jn+'.export'), fprof)
    # ... and config file as ./config.txt
    conf.WriteConfigTo(osp.join(reptrav, 'config.txt'))

    # 1.7. debug/nodebug
    dbg = prof['debug'][0]
    if dbg == '':
        dbg = 'nodebug'

    # 1.8. default values
    exetmp  = osp.join(REPREF, DbgPara[dbg]['exe'])
    cmdetmp = osp.join(REPREF, conf['BINCMDE'][0])
    eletmp  = osp.join(REPREF, conf['BINELE'][0])

    # 2. ----- read profile values
    # it's valid because exec, cmde and ele must appear only once
    # these values will be overidden if they are available in reptrav
    # after an occurence of 'make_...'
    if prof.Get('DR', 'exec'):
        exetmp  = prof.Get('DR', 'exec')[0]['path']
    if prof.Get('DR', 'cmde'):
        cmdetmp = prof.Get('DR', 'cmde')[0]['path']
    if prof.Get('DR', 'ele'):
        eletmp  = prof.Get('DR', 'ele')[0]['path']

    # order of actions :
    list_actions = ['make_exec',  'make_cmde', 'make_ele',
                   'make_etude', 'make_dbg',  'make_env', 'astout',
                   'distribution', 'multiple',
                   'exec_crs',   'exec_crp']

    # 3. ==> Let's go !
    # 3.0. check if we know what to do
    for act in prof['actions']:
        if act == '':
            run.Mess(_('nothing to do'), 'OK')
        elif not act in list_actions:
            run.Mess(_('unknown action : %s') % act, '<A>_ALARM')

    # check if the version allows developments
    if conf['DEVEL'][0] in NO_VALUES and \
        ( 'make_exec' in prof['actions'] or \
          'make_cmde' in prof['actions'] or \
          'make_ele' in prof['actions'] ):
        run.Mess(_('The configuration of this version does not allow '
                    'user developments.'), '<F>_ERROR')

    #
    # 3.1. ----- make_exec
    #
    iret = 0
    if 'make_exec' in prof['actions']:
        run.DBG('Start make_exec action')
        exetmp = osp.join(reptrav, 'aster.exe')
        tit = _('Compilation of source files')
        run.Mess(tit, 'TITLE')
        run.timer.Start(tit)

        repact = osp.join(reptrav, 'make_exec')
        repobj = osp.join(repact, 'repobj')
        run.MkDir(repact)
        lf = []
        for typ in ('c', 'f', 'f90'):
            for rep in [l['path'] for l in prof.Get('D', typ=typ)]:
                jret, lbi = build.Compil(typ.upper(), rep, repobj, dbg,
                                     rep_trav=repact, error_if_empty=True,
                                     numthread='auto')
                iret = max(iret, jret)
                lf.extend(lbi)
        # liste des fichiers surchargés
        vers = get_aster_version(REPREF)
        vers = '.'.join(vers[:3])
        fsurch = osp.join(repact, 'surchg.f')
        listsurcharge(vers, fsurch, lf)
        jret, lbi = build.Compil('F', fsurch, repobj, dbg, repact)
        run.timer.Stop(tit)
        run.CheckOK()

        tit = _('Build executable')
        run.Mess(tit, 'TITLE')
        run.timer.Start(tit)
        libaster = osp.join(REPREF, DbgPara[dbg]['libast'])
        libferm  = osp.join(REPREF, DbgPara[dbg]['libfer'])
        # for backward compatibility
        if run.IsDir(libaster):
            libaster = osp.join(libaster, 'lib_aster.lib')
        if run.IsDir(libferm):
            libferm = osp.join(libferm, 'ferm.lib')
        lobj = glob(osp.join(repobj, '*.o'))
        # build an archive if there are more than NNN object files
        if len(lobj) > 500:
            run.timer.Stop(tit)
            tit2 = _('Add object files to library')
            run.timer.Start(tit2)
            libtmp = osp.join(repobj, 'libsurch.a')
            run.Copy(libtmp, libaster)
            kret = build.Archive(repobj, libtmp, force=True)
            lobj = []
            libaster = libtmp
            run.timer.Stop(tit2)
            run.timer.Start(tit)
        kret = build.Link(exetmp, lobj, libaster, libferm, repact)
        run.timer.Stop(tit)
        run.CheckOK()

        tit = _('Copying results')
        run.timer.Start(tit, num=999)
        if prof.Get('R', typ='exec'):
            exe = prof.Get('R', typ='exec')[0]
            run.Delete(exe['path'], remove_dirs=False)
            iret = run.MkDir(osp.dirname(exe['path']))
            iret = run.Copy(exe['path'], exetmp)
            exedata = prof.Get('D', typ='exec')
            if exedata and exedata[0]['path'] != exe['path']:
                exetmp = exedata[0]['path']
        run.timer.Stop(tit)
        run.Mess(_('Code_Aster executable successfully created'), 'OK')

    #
    # 3.2. ----- make_cmde
    #
    if 'make_cmde' in prof['actions']:
        run.DBG('Start make_cmde action')
        tit = _("Compilation of commands catalogue")
        cmdetmp = osp.join(reptrav, 'cata_commande')
        run.timer.Start(tit)
        repact = osp.join(reptrav, 'make_cmde')
        run.MkDir(repact)
        kargs = { 'exe' : exetmp, 'cmde' : cmdetmp, }
        kargs['capy'] = [l['path'] for l in prof.Get('D', typ='capy')]
        lfun = prof.Get('D', typ='unig')
        if lfun:
            kargs['unigest'] = build.GetUnigest(lfun[0]['path'])
        if prof.Get('D', typ='py'):
            kargs['py'] = [l['path'] for l in prof.Get('D', typ='py')]
        jret = build.CompilCapy(REPREF, repact, **kargs)      #i18n=True,
        run.timer.Stop(tit)
        run.CheckOK()

        tit = _('Copying results')
        run.timer.Start(tit)
        if prof.Get('R', typ='cmde'):
            cmde = prof.Get('R', typ='cmde')[0]
            iret = run.MkDir(cmde['path'])
            iret = run.Copy(cmde['path'], osp.join(cmdetmp, 'cata*.py*'))
        run.timer.Stop(tit)

    #
    # 3.3. ----- make_ele
    #
    if 'make_ele' in prof['actions']:
        run.DBG('Start make_ele action')
        tit = _("Compilation of elements")
        eletmp = osp.join(reptrav, 'elem.1')
        run.timer.Start(tit)
        repact = osp.join(reptrav, 'make_ele')
        run.MkDir(repact)
        kargs = { 'exe' : exetmp, 'cmde' : cmdetmp, 'ele' : eletmp, }
        kargs['cata'] = [l['path'] for l in prof.Get('D', typ='cata')]
        lfun = prof.Get('D', typ='unig')
        if lfun:
            kargs['unigest'] = build.GetUnigest(lfun[0]['path'])
        if prof.Get('D', typ='py'):
            kargs['py'] = [l['path'] for l in prof.Get('D', typ='py')]
        jret = build.CompilEle(REPREF, repact, **kargs)
        run.timer.Stop(tit)
        run.CheckOK()

        tit = _('Copying results')
        run.timer.Start(tit)
        if prof.Get('R', typ='ele'):
            ele = prof.Get('R', typ='ele')[0]
            iret = run.MkDir(osp.dirname(ele['path']))
            iret = run.Copy(ele['path'], eletmp)
        run.timer.Stop(tit)

    #
    # 3.4. ----- make_env / make_etude / make_dbg
    #
    if 'make_env' in prof['actions'] or 'make_etude' in prof['actions'] or \
            'make_dbg' in prof['actions']:
        run.DBG('Start make_etude/make_env/make_dbg action')
        os.chdir(reptrav)
        run.Mess(_('Code_Aster execution'), 'TITLE')

        # 3.4.1. prepare reptrav to run Code_Aster (proc# = 0)
        only_env = 'make_env' in prof['actions']
        kargs = {
            'exe'  : exetmp,
            'cmde' : cmdetmp,
            'ele'  : eletmp,
            'lang' : prof['lang'][0],
            'only_env' : only_env,
        }
        lfun = prof.Get('D', typ='unig')
        if lfun:
            kargs['unigest'] = build.GetUnigest(lfun[0]['path'])
        if prof.Get('D', typ='py'):
            kargs['py'] = [l['path'] for l in prof.Get('D', typ='py')]
        tit = _('Preparation of environment')
        run.timer.Start(tit)
        run.Mess(ufmt(_('prepare environment in %s'), reptrav))
        if prof['prep_env'][0] != 'no':
            build.PrepEnv(REPREF, reptrav, dbg=dbg, **kargs)
        else:
            run.Mess(_('... skipped (%s = no) !') % 'prep_env', 'SILENT')
        run.timer.Stop(tit)

        # 3.4.2. copy datas (raise <E> errors if failed)
        tit = _('Copying datas')
        run.Mess(tit, 'TITLE')
        run.timer.Start(tit)
        if prof['copy_data'][0] not in NO_VALUES:
            copyfiles(run, 'DATA', prof)
        else:
            run.Mess(_('... skipped (%s = no) !') % 'copy_data', 'SILENT')
            print(os.getcwd())
        run.timer.Stop(tit)

        # 3.4.3. execution
        diag, tcpu, tsys, ttot, copybase = execute(
                reptrav,
                multiple       = False,
                with_dbg       = 'make_dbg' in prof['actions'],
                only_env       = only_env,
                runner         = runner,
                run=run, conf=conf, prof=prof, build=build, exe=exetmp)

        if not 'make_env' in prof['actions']:
            # 3.4.4. copy results
            tit = _('Copying results')
            run.Mess(tit, 'TITLE')
            run.timer.Start(tit)
            if prof['copy_result'][0] not in NO_VALUES:
                emit_alarm = prof['copy_result_alarm'][0] not in NO_VALUES
                copyfiles(run, 'RESU', prof, copybase, emit_alarm)
            else:
                run.Mess(_('... skipped (%s = no) !') % 'copy_result', 'SILENT')
            run.timer.Stop(tit)

            run.Mess(_('Code_Aster run ended'), diag)
            # 3.4.5. add .resu/.erre to output for testcases
            ctest  = prof['parent'][0] == "astout"
            if ctest and not build.support('noresu'):
                run.Mess(_('Content of RESU file'), 'TITLE')
                run.FileCat('fort.8', magic.get_stdout())
                run.Mess(_('Content of ERROR file'), 'TITLE')
                run.FileCat('fort.9', magic.get_stdout())

            # 3.4.6. notify the user
            if prof['notify'][0]:
                content = _('[Code_Aster] job %(job)s on %(server)s ended: %(diag)s')
                content = content % {
                    'job' : prof.get_jobname(),
                    'diag' : diag,
                    'server' : prof['serveur'][0],
                }
                dest = ','.join(prof['notify'])
                run.SendMail(dest=dest, text=content, subject=content.splitlines()[0])
                run.Mess(_('Email notification sent to %s') % dest)
            run.CheckOK()
        os.chdir(prev)

    # 3.5. ----- astout
    if 'astout' in prof['actions']:
        run.DBG('Start astout action')
        kargs = { 'exe'  : exetmp,
                'cmde' : cmdetmp,
                'ele'  : eletmp,
           'numthread' : prof['numthread'][0],
        }
        os.chdir(reptrav)
        RunAstout(run, conf, prof, runner=runner, **kargs)
        os.chdir(prev)

    # 3.6. ----- distribution
    if 'distribution' in prof['actions']:
        run.DBG('Start distribution action')
        kargs = { 'exe'  : exetmp,
                'cmde' : cmdetmp,
                'ele'  : eletmp,
           'numthread' : prof['numthread'][0],
        }
        Parametric(run, prof, runner=runner, **kargs)

    # 3.7. ----- multiple
    if 'multiple' in prof['actions']:
        run.DBG('Start multiple action')
        Multiple(run, prof, runner=runner, numthread=prof['numthread'][0])

    # 4. ----- clean up
    if 'make_env' in prof['actions'] and prof['detr_rep_trav'][0] not in NO_VALUES:
        run.DoNotDelete(reptrav)


def StartNow(run, *args):
    """Start quickly a simple execution using files in arguments.
    """
    if not run["silent"]:
        run.Mess(_("This functionnality is still in a beta state of development "
                   "and may be removed a future release, or may never be improved. "
                   "Please use --silent option to ignore this message the next time."))
    # ----- check argument
    if not run.get('aster_vers'):
        run.parser.error(_("You must define 'default_vers' in 'aster' configuration file or use '--vers' option."))
    if len(args) < 1:
        run.parser.error(_("'--%s' requires at least one argument") % run.current_action)

    # build export
    lf = [osp.abspath(f) for f in args]
    prof = build_export_from_files(run, lf, with_results=True)
    prof = use_options(run, prof)
    # development files
    surch_pyt = run.get('surch_pyt', [])
    if surch_pyt:
        for obj in surch_pyt.split(','):
            prof.Set('D', {
                'path' : osp.abspath(obj), 'type' : 'py',
                'ul'   : 0, 'isrep' : osp.isdir(osp.abspath(obj)),
                'compr' : False,
            })
    exetmp = None
    surch_fort = run.get('surch_fort', [])
    if surch_fort:
        for obj in surch_fort.split(','):
            prof.Set('D', {
                'path' : osp.abspath(obj), 'type' : 'f',
                'ul'   : 0, 'isrep' : osp.isdir(osp.abspath(obj)),
                'compr' : False,
            })
        exetmp = get_tmpname(run, run['tmp_user'], basename='executable')
        prof.Set('DR', {
            'path' : exetmp, 'type' : 'exec',
            'ul'   : 0, 'isrep' : False, 'compr' : False,
        })

    if exetmp is not None:
        prof['actions'] = prof['actions'] + ['make_exec']

    # try to grab all results files
    if run["copy_all_results"]:
        resudir = os.getcwd()
        lcomm = prof.get_type('comm')
        if len(lcomm) > 0:
            jobname = osp.splitext(osp.basename(lcomm[0].path))[0]
        else:
            jobname = 'unamed'
        add_all_results(prof, resudir, jobname)

    run.Mess(_("Profile used :"), 'TITLE')
    run.Mess(os.linesep + prof.get_content(), 'SILENT')
    # execution
    RunAster(run, prof)

def StartTestNow(run, *args):
    """Start a testcase in interactive mode"""
    # ----- check argument
    if not run.get('aster_vers'):
        run.parser.error(_("You must define 'default_vers' in 'aster' "
                           "configuration file or use '--vers' option."))
    if len(args) > 2:
        run.parser.error(_("'--%s' requires at most two arguments") % run.current_action)
    testcase = args[0]
    resutest = None
    if len(args) > 1:
        resutest = args[1]
    prof = get_export(run, testcase, resutest=resutest)
    prof = use_options(run, prof)
    conf = build_config_from_export(run, prof)
    addmem = 0.
    try:
        addmem = float(conf['ADDMEM'][0])
    except ValueError:
        pass
    memory = float(prof['memjob'][0] or 0.) / 1024. + addmem
    prof.set_param_memory(memory)
    # apply facmtps
    try:
        prof.set_param_time(int(
            float(prof['tpsjob'][0])) * 60. * float(prof['facmtps'][0]))
    except Exception:
        pass
    prof['parent'] = 'astout'
    run.Mess(_("starting %s") % testcase)
    RunAster(run, prof)

def use_options(run, prof):
    """use options to adjust the run"""
    from asrun.profile_modifier import apply_special_service
    # debug mode is enabled using -g/--debug option
    if run['debug']:
        prof['debug'] = 'debug'
    if run['debugger']:
        prof['actions'] = 'make_dbg'
    if run['exectool']:
        prof['exectool'] = run['exectool']
        serv, prof = apply_special_service(prof, run)
        assert serv == 'exectool', repr(prof)
    for parval in run['run_params']:
        decode = parval.strip().split('=', 1)
        assert len(decode) == 2, 'invalid syntax: %s' % parval
        par, val = decode
        if par == "args":
            prof.args[par] = (prof.args.get(par, "") + " " + val).strip()
        else:
            prof[par] = val
    return prof
