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
This modules gives functions to start up Code_Aster executions.
"""


import os
import os.path as osp
import re
import stat
from glob import glob
from math import log10
from warnings import warn

from asrun.installation import confdir
from asrun.common.i18n import _
from asrun.mystring     import convert, ufmt, file_cleanCR, to_unicode
from asrun.build        import glob_unigest
from asrun.runner       import Runner
from asrun.profil       import AsterProfil, ExportEntry
from asrun.common_func  import get_tmpname
from asrun.common.utils import getpara, check_joker, hms2s, make_writable
from asrun.common.sysutils import on_64bits


def dict_typ_test(test):
    """supported file types + ['com?', '[0-9]*']
    """
    return {
        'comm' : ('fort.1' ,  1),
        'mail' : ('fort.20', 20),
        'mmed' : ('fort.20', 20),
        'med'  : ('fort.20', 20),
        'datg' : ('fort.16', 16),
        'mgib' : ('fort.19', 19),
        'msh'  : ('fort.19', 19),
        'msup' : ('fort.19', 19),
        'para' : ('%s.para' % test, 0),
        'ensi' : ('DONNEES_ENSIGHT', 0),
        'repe' : ('REPE_IN', 0),
    }

def dict_typ_result():
    """supported file types : resu, rmed
    """
    return {
        'mess' : ('fort.6',   6),
        'resu' : ('fort.8',   8),
        'dat'  : ('fort.29', 29),
        'rmed' : ('fort.80', 80),
        'pos'  : ('fort.37', 37),
        'base' : ('unused',   0),
        'bhdf' : ('unused',   0),
    }



def execute(reptrav, multiple=False, with_dbg=False, only_env=False,
            follow_output=True, fpara=None, facmtps=1.,
            runner=None, **kargs):
    """Run a Code_Aster execution in 'reptrav'.
    Arguments :
        multiple : False if only one execution is run (so stop if it fails),
            True if several executions are run (don't stop when error occurs)
        with_dbg : start debugger or not,
        fpara    : deprecated,
        follow_output : print output to follow the execution,
    kargs give "run, conf, prof, build" instances + exec name
    Return a tuple (diag, tcpu, tsys, ttot, validbase).
    """
    # 1. ----- initializations
    run    = kargs['run']
    conf   = kargs['conf']
    prof   = kargs['prof']
    build  = kargs['build']
    exetmp = kargs['exe']
    ctest  = prof['parent'][0] == "astout"
    waf_inst = build.support('waf')
    waf_nosupv = build.support('nosuperv')
    waf_noresu = build.support('noresu')
    waf_orb = build.support('orbinitref')
    use_numthreads = build.support('use_numthreads')
    run.DBG("version supports: waf ({0}), nosuperv ({1}), "
            "orbinitref ({2}), numthreads ({3})".format(waf_inst, waf_nosupv,
            waf_orb, use_numthreads))
    if not waf_inst:
        exetmp = osp.join('.', osp.basename(exetmp))
    tcpu = 0.
    tsys = 0.
    ttot = 0.
    validbase = True
    if runner is None:
        runner = Runner()
        runner.set_rep_trav(reptrav)

    interact = ('interact' in prof.args or
                prof.args.get('args', '').find('-interact') > -1)
    hide_command = ("hide-command" in prof.args or
                    prof.args.get('args', '').find('--hide-command') > -1)

    os.chdir(reptrav)

    # 2. ----- list of command files
    list_comm = glob('fort.1.*')
    list_comm.sort()
    if osp.exists('fort.1'):
        list_comm.insert(0, 'fort.1')
    if waf_nosupv:
        for fcomm in list_comm:
            add_import_commands(fcomm)

    # 3. ----- arguments list
    drep = { 'REPOUT' : 'rep_outils', 'REPMAT' : 'rep_mat', 'REPDEX' : 'rep_dex' }
    cmd = []
    if waf_nosupv:
        if interact:
            cmd.append('-i')
        cmd.append('fort.1')
    else:
        if waf_inst:
            cmd.append(osp.join(conf['SRCPY'][0], conf['ARGPYT'][0]))
        else:
            cmd.append(osp.join(conf['REPPY'][0], conf['ARGPYT'][0]))
            cmd.extend(conf['ARGEXE'])
        # warning: using --commandes will turn off backward compatibility
        cmd.append('-commandes fort.1')
        # cmd.append(_fmtoption('command', 'fort.1'))

    # remove deprecated options
    long_opts_rm = ['rep', 'mem', 'mxmemdy', 'memory_stat', 'memjeveux_stat',
                    'type_alloc', 'taille', 'partition',
                    'origine', 'eficas_path']
    # for version < 12.6/13.2 that does not support --ORBInitRef=, ignore it
    if not waf_orb:
        long_opts_rm.append('ORBInitRef')
    cmd_memtps = {}
    for k, v in list(prof.args.items()):
        if k == 'args':
            cmd.append(prof.args[k])
        elif k in long_opts_rm:
            warn("this command line option is deprecated : --%s" % k,
                 DeprecationWarning, stacklevel=3)
        elif k in ('memjeveux', 'tpmax'):
            cmd_memtps[k] = v
        elif v.strip() == '' and k in list(drep.values()):
            run.Mess(_('empty value not allowed for "%s"') % k, '<A>_INVALID_PARAMETER')
        else:
            cmd.append(_fmtoption(k, v))

    # add arguments to find the process (for as_actu/as_del)
    if not 'astout' in prof['actions'] and not 'distribution' in prof['actions']:
        cmd.append(_fmtoption('num_job', run['num_job']))
        cmd.append(_fmtoption('mode', prof['mode'][0]))

    # arguments which can be set in file 'config.txt'
    for kconf, karg in list(drep.items()):
        if conf[kconf][0] != '' and not karg in list(prof.args.keys()):
            cmd.append(_fmtoption(karg, conf[kconf][0]))

    ncpus = prof['ncpus'][0]
    try:
        ncpus = max(1, int(ncpus))
    except ValueError:
        ncpus = ''
    if use_numthreads:
        if ncpus == '':
            ncpus = max([run[prof['mode'][0] + '_nbpmax'] // 2, 1])
        cmd.append(_fmtoption('numthreads', ncpus))
    elif ncpus == '':
        ncpus = '1'

    # 4. ----- add parameters from prof
    if on_64bits():
        facW = 8
    else:
        facW = 4
    tps   = 0
    memj  = 0
    nbp   = 0
    try:
        tps = int(float(prof.args['tpmax']))
    except KeyError:
        run.Mess(_('tpmax not provided in profile'), '<E>_INCORRECT_PARA')
    except ValueError:
        run.Mess(_('incorrect value for tpmax (%s) in profile') % \
                prof.args['tpmax'], '<E>_INCORRECT_PARA')
    try:
        memj = float(prof.args['memjeveux'])
    except KeyError:
        run.Mess(_('memjeveux not provided in profile'), '<E>_INCORRECT_PARA')
    except ValueError:
        run.Mess(_('incorrect value for memjeveux (%s) in profile') % \
                prof.args['memjeveux'], '<E>_INCORRECT_PARA')

    try:
        nbp = int(ncpus)
    except ValueError:
        run.Mess(_('incorrect value for ncpus (%s) in profile') % \
                prof['ncpus'][0], '<E>_INCORRECT_PARA')

    # 4.1. check for memory, time and procs limits
    run.Mess(_('Parameters : memory %d MB - time limit %d s') % (memj*facW, tps))
    check_limits(run, prof['mode'][0], tps, memj*facW, nbp, runner.nbnode(), runner.nbcpu())
    # check for previous errors (parameters)
    if not multiple:
        run.CheckOK()
    elif run.GetGrav(run.diag) > run.GetGrav('<A>'):
        run.Mess(_('error in parameters : %s') % run.diag)
        return run.diag, tcpu, tsys, ttot, validbase

    # 5. ----- only environment, print command lines to execute
    if only_env:
        run.Mess(ufmt(_('Code_Aster environment prepared in %s'), reptrav), 'OK')
        run.Mess(_('To start execution copy/paste following lines in a ksh/bash shell :'))
        run.Mess('   cd %s' % reptrav, 'SILENT')
        run.Mess('   . %s' % osp.join(confdir, 'profile.sh'), 'SILENT')
        tmp_profile = "profile_tmp.sh"
        with open(tmp_profile, 'w') as f:
            f.write("""
export PYTHONPATH=$PYTHONPATH:.
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:.
""")
        # set per version environment
        for f in conf.get_with_absolute_path('ENV_SH') + [tmp_profile]:
            run.Mess('   . %s' % f, 'SILENT')

        cmd.insert(0, exetmp)
        # add memjeveux and tpmax
        cmd.extend([_fmtoption(k, v) for k, v in list(cmd_memtps.items())])
        cmdline = ' '.join(cmd)

        # get pdb.py path
        pdbpy_cmd = "import os, sys ; " \
            "pdbpy = os.path.join(sys.prefix, 'lib', 'python' + sys.version[:3], 'pdb.py')"
        d = {}
        exec(pdbpy_cmd, d)
        pdbpy = d['pdbpy']

        if runner.really():  #XXX and if not ? perhaps because of exit_code
            cmdline = runner.get_exec_command(cmdline,
                add_tee=False,
                env=conf.get_with_absolute_path('ENV_SH'))

        # print command lines
        k = 0
        for fcomm in list_comm:
            k += 1
            run.Mess(_("Command line %d :") % k)
            run.Mess("cp %s fort.1" % fcomm, 'SILENT')
            run.Mess(cmdline, 'SILENT')
            # how to start the Python debugger
            if not runner.really():
                run.Mess(_('To start execution in the Python debugger you could type :'), 'SILENT')
                pdb_cmd = cmdline.replace(exetmp,
                    '%s %s' % (exetmp, ' '.join(pdbpy.splitlines())))
                run.Mess("cp %s fort.1" % fcomm, 'SILENT')
                run.Mess(pdb_cmd, 'SILENT')

        diag = 'OK'

    # 6. ----- really execute
    else:
        # 6.1. content of reptrav
        if not ctest:
            run.Mess(ufmt(_('Content of %s before execution'), reptrav), 'TITLE')
            out = run.Shell(cmd='ls -la')[1]
            print(out)

        if len(list_comm) == 0:
            run.Mess(_('no .comm file found'), '<E>_NO_COMM_FILE')
        # check for previous errors (copy datas)
        if not multiple:
            run.CheckOK()
        elif run.GetGrav(run.diag) > run.GetGrav('<A>'):
            run.Mess(_('error occurs during preparing data : %s') % run.diag)
            return run.diag, tcpu, tsys, ttot, validbase

        # 6.2. complete command line
        cmd.append('--suivi_batch')
        add_tee = False
        if with_dbg:
            # how to run the debugger
            cmd_dbg = run.config.get('cmd_dbg', '')
            if not cmd_dbg:
                run.Mess(_('command line to run the debugger not defined'),
                        '<F>_DEBUG_ERROR')
            if cmd_dbg.find('gdb') > -1:
                ldbg = ['break main', ]
            else:
                ldbg = ['stop in main', ]
            # add memjeveux and tpmax
            update_cmd_memtps(cmd_memtps)
            cmd.extend([_fmtoption(k, v) for k, v in list(cmd_memtps.items())])
            pos_memtps = -1

            cmd_args = ' '.join(cmd)
            ldbg.append('run ' + cmd_args)
            cmd = getdbgcmd(cmd_dbg, exetmp, '', ldbg, cmd_args)
        else:
            add_tee = True
            cmd.insert(0, exetmp)
            # position where insert memjeveux+tpmax
            pos_memtps = len(cmd)
            # keep for compatibility with version < 13.1
            os.environ['OMP_NUM_THREADS'] = str(ncpus)
            # unlimit coredump size
            try:
                corefilesize = int(prof['corefilesize'][0]) * 1024*1024
            except ValueError:
                corefilesize = 'unlimited'
            run.SetLimit('core', corefilesize)

        # 6.3. if multiple .comm files, keep previous bases
        if len(list_comm) > 1:
            run.Mess(_('%d command files') % len(list_comm))
            validbase = False
            BASE_PREC = osp.join(reptrav, 'BASE_PREC')
            run.MkDir(BASE_PREC)

        # 6.4. for each .comm file
        diag = '?'
        diag_ok = None
        k = 0
        for fcomm in list_comm:
            k += 1
            os.chdir(runner.reptrav())
            run.Copy('fort.1', fcomm)

            # start execution
            tit = _('Code_Aster run')
            run.timer.Start(tit)

            # add memjeveux and tpmax at the right position
            cmd_i = cmd[:]
            update_cmd_memtps(cmd_memtps)
            if pos_memtps > -1:
                for key, value in list(cmd_memtps.items()):
                    cmd_i.insert(pos_memtps, _fmtoption(key, value))

            if True or not ctest:
                run.Mess(tit, 'TITLE')
                run.Mess(_('Command line %d :') % k)
                if not run['verbose']:
                    run.Mess(' '.join(cmd_i))
                if waf_nosupv and not hide_command:
                    dash = "# " + "-" * 90
                    with open('fort.1', 'rb') as f:
                        content =[_("Content of the file to execute"),
                                  dash,
                                  to_unicode(f.read()),
                                  dash]
                    run.Mess(os.linesep.join(content))

            cmd_exec = runner.get_exec_command(' '.join(cmd_i),
                add_tee=add_tee,
                env=conf.get_with_absolute_path('ENV_SH'))

            # go
            iret, exec_output = run.Shell(cmd_exec, follow_output=follow_output, interact=interact)
            if iret != 0:
                cats = ['fort.6']
                if not waf_noresu:
                    cats.extend(['fort.8', 'fort.9'])
                for f in cats:
                    run.FileCat(text="""\n <I>_EXIT_CODE = %s""" % iret, dest=f)
            if not follow_output and not ctest:
                print(exec_output)

            # mpirun does not include cpu/sys time of childrens, add it in timer
            runner.add_to_timer(exec_output, tit)

            run.timer.Stop(tit)
            if k < len(list_comm):
                for b in glob('vola.*')+glob('loca.*'):
                    run.Delete(b)

            if len(list_comm) > 1:
                ldiag = build.getDiag(cas_test=ctest)
                diag_k  = ldiag[0]
                tcpu += ldiag[1]
                tsys += ldiag[2]
                ttot += ldiag[3]
                run.FileCat('fort.6', 'fort_bis.6')
                run.Delete('fort.6')
                if not waf_noresu:
                    run.FileCat('fort.8', 'fort_bis.8')
                    run.Delete('fort.8')
                    run.FileCat('fort.9', 'fort_bis.9')
                    run.Delete('fort.9')
                if re.search('<[ESF]{1}>', diag_k):
                    # switch <F> to <E> if multiple .comm
                    if diag_k.find('<F>') > -1:
                        diag_k = diag_k.replace('<F>', '<E>')
                        # ...and try to restore previous bases
                        run.Mess(ufmt(_('restore bases from %s'), BASE_PREC))
                        lbas = glob(osp.join(BASE_PREC, 'glob.*')) + \
                         glob(osp.join(BASE_PREC, 'bhdf.*')) + \
                         glob(osp.join(BASE_PREC, 'pick.*'))
                        if len(lbas) > 0:
                            run.Copy(os.getcwd(), niverr='INFO', verbose=follow_output, *lbas)
                        else:
                            run.Mess(_('no glob/bhdf base to restore'), '<A>_ALARM')
                    run.Mess(_('execution aborted (comm file #%d)') % k, diag_k)
                    diag = diag_k
                    break
                else:
                    # save bases in BASE_PREC if next execution fails
                    validbase = True
                    if k < len(list_comm):
                        if not ctest:
                            run.Mess(ufmt(_('save bases into %s'), BASE_PREC))
                        lbas = glob('glob.*') + \
                         glob('bhdf.*') + \
                         glob('pick.*')
                        run.Copy(BASE_PREC, niverr='INFO', verbose=follow_output, *lbas)
                    run.Mess(_('execution ended (comm file #%d)') % k, diag_k)
                # at least one is ok/alarm ? keep the "worse good" status!
                if run.GetGrav(diag_k) in (0, 1):
                    diag_ok = diag_ok or 'OK'
                    if run.GetGrav(diag_ok) < run.GetGrav(diag_k):
                        diag_ok = diag_k
                # the worst diagnostic
                if run.GetGrav(diag) < run.GetGrav(diag_k):
                    diag = diag_k

        # 6.5. global diagnostic
        if len(list_comm) > 1:
            run.Rename('fort_bis.6', 'fort.6')
            run.Rename('fort_bis.8', 'fort.8')
            run.Rename('fort_bis.9', 'fort.9')
        else:
            diag, tcpu, tsys, ttot = build.getDiag(cas_test=ctest)[:4]
            validbase = run.GetGrav(diag) <= run.GetGrav('<S>')
        if ctest and run.GetGrav(diag) < 0:
            diag = '<F>_' + diag
        if ctest and diag == 'NO_TEST_RESU' and diag_ok:
            diag = diag_ok
            run.ReinitDiag(diag)
        # expected diagnostic ?
        if prof['expected_diag'][0]:
            expect = prof['expected_diag'][0]
            if run.GetGrav(diag) >= run.GetGrav('<E>'):
                diag = '<F>_ERROR'
            if run.GetGrav(diag) == run.GetGrav(expect):
                run.Mess(_('Diagnostic is as expected.'))
                diag = 'OK'
            else:
                run.Mess(_("Diagnostic is not as expected (got '%s').") % diag)
                diag = 'NOOK_TEST_RESU'
            run.ReinitDiag(diag)
        run.Mess(_('Code_Aster run ended, diagnostic : %s') % diag)

        # 6.6. post-mortem analysis of the core file
        if not with_dbg:
            cmd_dbg = run.config.get('cmd_post', '')
            lcor = glob('core*')
            if cmd_dbg and lcor:
                run.Mess(_('Code_Aster run created a coredump'),
                        '<E>_CORE_FILE')
                if not multiple:
                    # take the first one if several core files
                    core = lcor[0]
                    run.Mess(ufmt(_('core file name : %s'), core))
                    cmd = getdbgcmd(cmd_dbg, exetmp, core,
                            ('where', 'quit'), '')
                    tit = _('Coredump analysis')
                    run.Mess(tit, 'TITLE')
                    run.timer.Start(tit)
                    iret, output = run.Shell(' '.join(cmd),
                            alt_comment='coredump analysis...', verbose=True)
                    if iret == 0 and not ctest:
                        print(output)
                    run.timer.Stop(tit)

        if not ctest:
            # 6.7. content of reptrav
            run.Mess(ufmt(_('Content of %s after execution'), os.getcwd()), 'TITLE')
            out = run.Shell(cmd='ls -la . REPE_OUT')[1]
            print(out)

            # 6.8. print some informations
            run.Mess(_('Size of bases'), 'TITLE')
            lf = glob('vola.*')
            lf.extend(glob('loca.*'))
            lf.extend(glob('glob.*'))
            lf.extend(glob('bhdf.*'))
            lf.extend(glob('pick.*'))
            for f in lf:
                run.Mess(_('size of %s : %12d bytes') % (f, os.stat(f).st_size))

    return diag, tcpu, tsys, ttot, validbase


def _fmtoption(key, value=None):
    """Format an option"""
    key = key.lstrip('-')
    if value is None or (type(value) is str and not value.strip()):
        fmt = '--{0}'.format(key)
    else:
        fmt = '--{0}={1}'.format(key, value)
    return fmt

def copyfiles(run, mode, prof, copybase=True, alarm=True):
    """Copy datas from profile into `pwd` (if mode=='DATA')
    or results from `pwd` into destination given by profile (if mode=='RESU').
    Aster bases are copied only if copybase is True.
    Raise only <E> if an error occurs run CheckOK() after.
    """
    if mode == 'DATA':
        l_dico = prof.data
        icomm = 0
        ncomm = len(prof.Get('D', 'comm'))
        for df in l_dico:
            icomm = copyfileD(run, df, icomm, ncomm)
    else:
        l_dico = prof.resu
        for df in l_dico:
            copyfileR(run, df, copybase, alarm)


def copyfileD(run, df, icomm, ncomm):
    """Copy datas from `df` into current directory.
    Raise only <E> if an error occurs run CheckOK() after.
    """
    dest = None
    # 1. ----- if logical unit is set : fort.*
    if df['ul'] != 0 or df['type'] in ('nom',):
        dest = 'fort.%d' % df['ul']
        if df['type'] == 'nom':
            dest = osp.basename(df['path'])
        # exception for multiple command files (adding _N)
        if df['ul'] == 1:
            icomm += 1
            format = '%%0%dd' % (int(log10(max(1, ncomm))) + 1)
            dest = dest + '.' + format % icomm
        # warning if file already exists
        if run.Exists(dest):
            run.Mess(ufmt(_("'%s' overwrites '%s'"), df['path'], dest), '<A>_COPY_DATA')
        if df['compr']:
            dest = dest + '.gz'

    # 2. ----- bases and directories (ul=0)
    else:
        # base
        if df['type'] in ('base', 'bhdf'):
            dest = osp.basename(df['path'])
        # ensi
        elif df['type'] == 'ensi':
            dest = 'DONNEES_ENSIGHT'
        # repe
        elif df['type'] == 'repe':
            dest = 'REPE_IN'

    if dest is not None:
        # 3. --- copy
        kret = run.Copy(dest, df['path'], niverr='<E>_COPY_ERROR', verbose=True)

        # 4. --- decompression
        if kret == 0 and df['compr']:
            kret, dest = run.Gunzip(dest, niverr='<E>_DECOMPRESSION', verbose=True)

        # 5. --- move the bases in main directory
        if df['type'] in ('base', 'bhdf'):
            for f in glob(osp.join(dest, '*')):
                run.Rename(f, osp.basename(f))

        # force the file to be writable
        make_writable(dest)

        # clean text files if necessary
        if df['ul'] != 0 and run.IsTextFileWithCR(dest):
            file_cleanCR(dest)
            print(ufmt(' ` ' + _('line terminators have been removed from %s'), dest))
    return icomm


def copyfileR(run, df, copybase=True, alarm=True):
    """Copy results from current directory into destination given by `df`.
    Aster bases are copied only if copybase is True.
    Raise only <E> if an error occurs run CheckOK() after.
    """
    # list of files
    lf = []
    isdir = False

    # 1. ----- files
    if df['ul'] != 0 or df['type'] in ('nom', ):
        # if logical unit is set : fort.*
        if df['ul'] != 0:
            lf.append('fort.%d' % df['ul'])
        elif df['type'] == 'nom':
            lf.append(osp.basename(df['path']))

    # 2. ----- bases and directories (ul=0)
    else:
        isdir = True
        # base
        if df['type'] == 'base' and copybase:
            lf.extend(glob('glob.*'))
            lf.extend(glob('pick.*'))
        # bhdf
        elif df['type'] == 'bhdf' and copybase:
            lbas = glob('bhdf.*')
            if len(lbas) == 0:
                if alarm:
                    run.Mess(_("No 'bhdf' found, saving 'glob' instead"), '<A>_COPY_BASE')
                lbas = glob('glob.*')
            lf.extend(lbas)
            lf.extend(glob('pick.*'))
        # repe
        elif df['type'] == 'repe':
            rep = 'REPE_OUT'
            lfrep = glob(osp.join(rep, '*'))
            if len(lfrep) == 0 and alarm:
                run.Mess(ufmt(_("%s directory is empty !"), rep), '<A>_COPY_REPE')
            lf.extend(lfrep)

    # 3. ----- compression
    kret = 0
    if df['compr']:
        lfnam = lf[:]
        lf = []
        for fnam in lfnam:
            kret, f = run.Gzip(fnam, niverr='<E>_COMPRES_ERROR', verbose=True)
            if kret == 0:
                lf.append(f)
            else:
                lf.append(fnam)
                run.Mess(_("Warning: The uncompressed file will be returned "
                           "without changing the target filename\n(eventually "
                           "ending with '.gz' even if it is not compressed; "
                           "you may have to rename it before use)."),
                         '<A>_COPYFILE')

    # 4. ----- copy
    if len(lf) > 0:
        # create destination
        if isdir:
            kret = run.MkDir(df['path'], '<E>_MKDIR_ERROR')
        else:
            if len(lf) > 1:
                run.Mess(ufmt(_("""Only the first one of [%s] is copied."""), ', '.join(lf)),
                        '<A>_COPYFILE')
            lf = [lf[0],]
            kret = run.MkDir(osp.dirname(df['path']), '<E>_MKDIR_ERROR')
        # copy
        if kret == 0:
            lfc = lf[:]
            for fname in lfc:
                if not osp.exists(fname):
                    if alarm:
                        run.Mess(ufmt("no such file or directory: %s", fname), '<A>_COPYFILE')
                    lf.remove(fname)
            if len(lf) > 0:
                kret = run.Copy(df['path'], niverr='<E>_COPY_ERROR', verbose=True, *lf)
        # save base if failure
        if kret != 0:
            rescue = get_tmpname(run, basename='save_results')
            run.Mess(ufmt(_("Saving results in a temporary directory (%s)."), rescue),
                    '<A>_COPY_RESULTS', store=True)
            kret = run.MkDir(rescue, chmod=0o700)
            kret = run.Copy(rescue, niverr='<E>_COPY_ERROR',
                    verbose=True, *lf)


def build_test_export(run, conf, REPREF, reptest, test, resutest=None,
                      with_default=True, d_unig=None):
    """Return a profile for a testcase.
    """
    lrep = [osp.join(REPREF, dt) for dt in conf['SRCTEST']]
    if reptest:
        lrep.extend(reptest)
    for rep in lrep:
        if run.IsRemote(rep):
            run.Mess(ufmt(_('reptest (%s) must be on exec host'), rep),
                    '<F>_INVALID_DIR')
    lrep = [run.PathOnly(rep) for rep in lrep]
    lrm = []
    if d_unig:
        d_unig = glob_unigest(d_unig, REPREF)
        lrm = set([osp.basename(f) for f in d_unig['test']])

    export = _existing_file(test + '.export', lrep, last=True)
    # new testcase with .export
    if export:
        prof = AsterProfil(run=run)
        if with_default:
            prof.add_default_parameters()
        pexp = AsterProfil(export, run)
        pexp.set_param_limits()
        for entry in pexp.get_data():
            if osp.basename(entry.path) in lrm:
                run.Mess(ufmt(_('deleting %s (matches unigest)'),
                              osp.basename(entry.path)))
                pexp.remove(entry)
            found = _existing_file(entry.path, lrep, last=True)
            if found is None:
                run.Mess(ufmt(_('file not found : %s'), entry.path),
                                 '<E>_FILE_NOT_FOUND')
                pexp.remove(entry)
            else:
                entry.path = found
        pexp._compatibility()
        prof.update(pexp)
    else:
    # old version using .para
        lall = []
        for r in lrep:
            f = osp.join(r, '%s.*' % test)
            lall.extend(glob(f))
        lf = []
        for f in lall:
            if osp.basename(f) in lrm:
                run.Mess(ufmt(_('deleting %s (matches unigest)'), osp.basename(f)))
            else:
                lf.append(f)
        if not lf:
            run.Mess(ufmt(_('no such file : %s.*'), test),
                             '<E>_FILE_NOT_FOUND')
        prof = build_export_from_files(run, lf, test, with_default=with_default)
    if resutest:
        ftyp = { 'resu' : 8, 'mess' : 6, 'code' : 15 }
        for typ, ul in list(ftyp.items()):
            new = ExportEntry(osp.join(resutest, '%s.%s' % (test, typ)),
                              type=typ, ul=ul,
                              result=True)
            prof.add(new)
    return prof


def build_export_from_files(run, lf, root="", with_default=True, with_results=False):
    """Build an export file from a list of files.
    """
    prof = AsterProfil(run=run)
    if with_default:
        prof.add_default_parameters()
    ddat = build_dict_file(run, prof, dict_typ_test(root), lf, ['com?', '[0-9]*'])
    dres = {}
    if with_results:
        dres = build_dict_file(run, prof, dict_typ_result(), lf)

    for dicf, dr in ((ddat, 'D'), (dres, 'R')):
        lcom_i = []
        for f, dico in list(dicf.items()):
            if dico['type'] != 'comm' or osp.splitext(f)[-1] == '.comm':
                prof.Set(dr, dico)
            else:
                lcom_i.append([f, dico])
        lcom_i.sort()
        for f, dico in lcom_i:
            prof.Set(dr, dico)
    return prof


def build_dict_file(run, prof, dtyp, lf, opt_suffix=[]):
    """Build the dictionnary of files 'lf' matching the types defined
    in 'dtyp'."""
    dvu = {}
    for typ0 in list(dtyp.keys()) + opt_suffix:
        if typ0 == 'comm':    # always in com?
            continue
        for f in lf:
            typ = typ0
            if not check_joker(f, "."+typ):
                continue
            base = osp.basename(f)
            if dvu.get(base):
                run.DBG("'%s' overwrites by '%s'" % (base, f))
            if typ == 'para':
                iret, dico, msg = getpara(f, run['plate-forme'])
                if iret != 0:
                    run.DBG("ERROR getpara :", msg)
                prof.add_param_from_dict(dico)
                continue
            if typ[:3] == 'com':   # comm ou com?
                typ = 'comm'
                ul  = 1
            elif dtyp.get(typ) != None:
                ul  = dtyp[typ][1]
            else:
                typ = 'libr'
                try:
                    ul  = int(f.split('.')[-1])
                except ValueError:
                    ul = 0
            dvu[base] = { 'type'  : typ,
                          'isrep' : False,
                          'path'  : f,
                          'ul'    : ul,
                          'compr' : False }
    return dvu

def add_all_results(prof, dest, jobname, dtyp=None):
    """Add all known results files to 'prof'."""
    if dtyp is None:
        dtyp = dict_typ_result
    prof['copy_result_alarm'] = 'no'
    for typ, value in list(dtyp().items()):
        if typ in ('base', 'bhdf'):
            continue
        path = osp.join(dest, "%s.%s" % (jobname, typ))
        ul = value[1]
        prof.Set('R',
            { 'path' : path, 'ul' : ul, 'type' : typ,
              'isrep' : False, 'compr' : False})

def getdbgcmd(cmd_dbg, exe, core, lcmd, args):
    """Return the command line (as list) to run 'lcmd' in the debugger.
        @E : executable
        @C : coredump filename
        @D : filename of debugger commands
        @d : string of debugger commands
    """
    # debugger commands string
    cstr = ' ; '.join(lcmd)
    ftmp = 'dbg_cmdfile'
    # fill debugger commands file
    f = open(ftmp, 'w')
    f.write(os.linesep.join(lcmd) + os.linesep)
    f.close()
    # replace @ codes
    cmd = cmd_dbg.replace('@E', exe)
    cmd = cmd.replace('@C', core)
    cmd = cmd.replace('@D', ftmp)
    cmd = cmd.replace('@d', cstr)
    cmd = cmd.replace('@a', args)
    return [cmd]


def check_limits(run, mode, tps, mem, nbp, mpi_nbnoeud, mpi_nbcpu):
    """Return True if args are less than limits defined in
    configuration file, False else.
    """
    # time
    try:
        tpsmax = hms2s(run[mode+'_tpsmax'])
    except ValueError:
        run.Mess(_('Incorrect value (%s) for %s') % \
                (str(run[mode+'_tpsmax']), mode+'_tpsmax'), '<F>_CONFIG_ERROR')
    if tps > tpsmax:
        run.Mess(_("""Requested time (%s s) is higher than the limit (%s s)""") % \
                (tps, tpsmax), '<E>_INCORRECT_PARA')
    # memory
    try:
        limit = int(run[mode+'_memmax'])
    except ValueError:
        run.Mess(_('Incorrect value (%s) for %s') % \
                (str(run[mode+'_memmax']), mode+'_memmax'), '<F>_CONFIG_ERROR')
    if mem > limit:
        run.Mess(_("""Requested memory (%s MB) is higher than the limit (%s MB)""")%\
                (mem, limit), '<E>_INCORRECT_PARA')
    # ncpus
    try:
        limit = int(run[mode+'_nbpmax'])
    except ValueError:
        run.Mess(_('Incorrect value (%s) for %s') % \
                (str(run[mode+'_nbpmax']), mode+'_nbpmax'), '<F>_CONFIG_ERROR')
    if nbp > limit:
        run.Mess(_("""Requested number of processors (%s) is higher than the limit (%s)""") %\
                (nbp, limit), '<E>_INCORRECT_PARA')
    # mpi nbcpu
    para = mode + '_mpi_nbpmax'
    try:
        limit = int(run.get(para, 1))
    except ValueError:
        run.Mess(_('Incorrect value (%s) for %s') % \
                (str(run.get(para, 1)), para), '<F>_CONFIG_ERROR')
    if mpi_nbcpu > limit:
        run.Mess(_("""Requested number of MPI processors (%s) is higher than the limit (%s)""") %\
                (mpi_nbcpu, limit), '<E>_INCORRECT_PARA')


def update_cmd_memtps(dico):
    """Met à jour (ou non) les infos du dictionnaire contenant memjeveux et tpmax.
    On traite uniquement : info_cpu (produit par E_JDC.py)
    """
    # dictionnaire des infos lues
    d = {}
    try:
        with open('info_cpu', 'r') as f:
            content = f.read().splitlines()
        l_str = content[0].split()
        l_fl = [float(s) for s in l_str]
        d['cpu_total'], d['cpu_total_user'], d['cpu_total_syst'], d['cpu_restant'] = l_fl
    except:
        pass
    # new values
    dnew = {}
    # tpmax
    if d.get('cpu_restant') is not None:
        dnew['tpmax'] = int(d['cpu_restant'])
    dico.update(dnew)


def _existing_file(fname, l_paths, last=False):
    """Return the first (or `last` if True) existing file in `l_paths`.
    Return None if `fname` is not found."""
    l_paths = l_paths[:]
    if last:
        l_paths.reverse()
    path = None
    for dirn in l_paths:
        if osp.exists(osp.join(dirn, fname)):
            path = osp.join(dirn, fname)
            break
    return path


def add_import_commands(filename):
    """Add import of code_aster commands if not present.

    Arguments:
        filename (str): Path of the comm file to check.
    """
    with open(filename, 'r') as fobj:
        txt = fobj.read()

    re_done = re.compile(r"^from +code_aster\.Commands", re.M)
    if re_done.search(txt):
        return

    re_init = re.compile("^(?P<init>(DEBUT|POURSUITE))", re.M)
    if re_init.search(txt):
        starter = r"\g<init>"
    else:
        starter = "code_aster.init()\n"

    re_replacement = \
r"""
# temporarly added for compatibility with code_aster legacy
from math import *

import code_aster
from code_aster.Commands import *

{starter}"""

    txt = re_init.sub(re_replacement.format(starter=starter), txt)
    txt = convert(txt, encoding="utf-8")
    re_coding = re.compile(r'^#( *(?:|\-\*\- *|en)coding.*)' + '\n', re.M)
    if not re_coding.search(txt):
        txt = "# coding=utf-8\n" + txt
    with open(filename, 'w') as fobj:
        fobj.write(txt)
