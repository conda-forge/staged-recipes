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
Defines a function to run a list of testcases
"""

import os
import os.path as osp
import random
import pickle

from asrun.common.i18n  import _
from asrun.build        import AsterBuild
from asrun.mystring     import ufmt
from asrun.thread       import Dispatcher
from asrun.distrib      import DistribTestTask
from asrun.repart       import get_hostrc
from asrun.common_func  import get_tmpname
from asrun.maintenance  import get_aster_version, repr_vers, getDiagnostic
from asrun.common.utils import get_list, now, YES_VALUES


fmt_head = '%s %s %s %s %s %s' % (_("testcase").center(12), _("result").center(18),
        _("cpu").rjust(8), _("sys").rjust(8), _("cpu+sys").rjust(8), _("elapsed").rjust(8) )
fmt_resu = '%-12s %-18s %8.2f %8.2f %8.2f %8.2f'
fmt_res2 = '%%4d %s %%4d %s    %%8.2f %%8.2f %%8.2f %%8.2f' \
    % (_("tests").ljust(7), _("errors").ljust(10))
fmt_tot = '-'*12+' '+'-'*18+' '+'-'*8+' '+'-'*8+' '+'-'*8+' '+'-'*8


def RunAstout(run, conf, prof, runner, numthread='auto', **kargs):
    """Run a list of test cases...
    """
    run.print_timer = True

    # 1. ----- initializations
    REPREF = prof.get_version_path()

    # 1.2. rep_trav from profile or from run[...]
    reptrav = runner.reptrav()

    run.Mess(_('Code_Aster tests execution'), 'TITLE')
    runner.set_cpuinfo(1, 1)

    # ----- how many threads ?
    try:
        numthread = int(numthread)
    except (TypeError, ValueError):
        numthread = run.GetCpuInfo('numthread')

    # 1.3. content of the profile
    ltest = osp.join(reptrav, 'tests.list')
    if not prof.Get('D', typ='list'):
        run.Mess(_('no list of tests found'), '<E>_NO_TEST_LIST')
    else:
        for dli in prof.Get('D', typ='list'):
            if run.IsRemote(dli['path']):
                tmplist = get_tmpname(run, run['tmp_user'], basename='list')
                run.ToDelete(tmplist)
                kret = run.Copy(tmplist, dli['path'])
                run.FileCat(tmplist, ltest)
            else:
                tmplist = run.PathOnly(dli['path'])
                run.FileCat(tmplist, ltest)
    if not prof.Get('D', typ='rep_test'):
        reptest = []
    else:
        reptest = [r['path'] for r in prof.Get('D', typ='rep_test')]
    if not prof.Get('R', typ='resu_test'):
        run.Mess(_('no result directory found'), '<E>_NO_RESU_DIR')
    else:
        resutest = prof.Get('R', typ='resu_test')[0]['path']
        if run.IsRemote(resutest):
            run.Mess(_('the result directory must not be on a remote host'), '<F>_ERROR')
        resutest = run.PathOnly(resutest)
        run.MkDir(resutest)
        run.Delete(osp.join(resutest, 'RESULTAT'))
        run.Delete(osp.join(resutest, 'NOOK'))
        flashdir = osp.join(resutest, 'flash')
        prfl = prof.Get('R', typ='flash')
        if prfl:
            if prfl[0]['path'] == "None":
                flashdir = None
            else:
                flashdir = prfl[0]['path']

    facmtps = 1.
    nbmaxnook = 5
    cpresok = 'RESNOOK'
    try:
        if prof['facmtps'][0] != '':
            facmtps   = float(prof['facmtps'][0])
    except ValueError:
        run.Mess(_('incorrect value for %s : %s') % ('facmtps', prof['facmtps'][0]))
    try:
        if prof['nbmaxnook'][0] != '':
            nbmaxnook = int(prof['nbmaxnook'][0])
    except ValueError:
        run.Mess(_('incorrect value for %s : %s') % ('nbmaxnook', prof['nbmaxnook'][0]))
    if prof['cpresok'][0] != '':
        cpresok   = prof['cpresok'][0]
    run.CheckOK()

    # get the list of the tests to execute
    iret, list_tests = get_list(ltest, unique=True)
    if iret != 0:
        run.Mess(_('error during reading file : %s') % ltest, '<F>_ERROR')
    nbtest = len(list_tests)

    # should we run only nook tests ?
    if run['only_nook'] or prof['only_nook'][0] in YES_VALUES:
        build = AsterBuild(run, conf)
        l_dirs = reptest + [resutest]
        old_run_result = getDiagnostic(run, build, l_dirs, list_tests)
        run.DBG('getDiagnostic result', old_run_result, all=True)
        nbini = len(list_tests)
        list_tests = []
        for test, dres in list(old_run_result.items()):
            if test.startswith('__'):
                continue
            if run.GetGrav(dres['diag']) >= run.GetGrav('NOOK'):
                list_tests.append(test)
        nbtest = len(list_tests)
        print(_("""
--- %d test-cases to run initially
    %d test-cases previously failed (or their results have not been found) and will be run again
""") % (nbini, nbtest))

    random.shuffle(list_tests)

    # suivi des calculs partagé entre 'numthread' threads
    tit = _("Checking hosts")
    hostrc = get_hostrc(run, prof)
    run.timer.Start(tit)
    n_avail, n_tot = hostrc.CheckHosts(run, numthread=numthread)
    run.timer.Stop(tit)
    run.Mess(_('Number of available hosts : %d/%d') % (n_avail, n_tot), "SILENT")
    if n_avail < 1:
        run.Mess(_("No available host. Run cancelled."), "<F>_INVALID_PARAMETER")

    # timeout before rejected a job = tpsjob
    try:
        timeout = prof.get_timeout()
    except Exception as reason:
        run.Mess(_("incorrect value for tpsjob : %s") % reason, '<F>_INVALID_PARAMETER')

    # print a summary
    summary = _("""
--- %d test-cases to run
--- Run started at %s
--- Parameters used for this run :
    Directory of reference files    : %s
    Directory of developper files   : %s
    Directory to copy results       : %s
    Directory for job files         : %s
    Code_Aster version              : %s (%s)
    Executable filename             : %s
    Commands catalogue directory    : %s
    Elements catalogue filename     : %s
    Maximum number of errors (NOOK) : %d
    Criteria to copy result files   : %s
    Time multiplicative factor      : %f
    Working directory               : %s
    Submission timeout (seconds)    : %.0f""")

    sum_thread = _("""    Number of threads               : %d""")
    sum_rc     = _("""    Available hosts (resources)     : %s""")
    sum_end = _("""
--- All tests finished at %s

--- Results :
""")
    fmt_spup = _("""
--- Speed-up is %.2f
""")
    version_number = '.'.join(get_aster_version(REPREF)[:3])
    info_start = ( nbtest, now(),
        ', '.join([osp.join(REPREF, path) for path in conf['SRCTEST']]),
        ', '.join(reptest), resutest, flashdir,
        prof.get_version_path(), version_number,
        kargs['exe'], kargs['cmde'], kargs['ele'],
        nbmaxnook, cpresok, facmtps, reptrav, timeout )
    txt_summary = [ ufmt(summary, *info_start), ]
    if numthread > 1:
        txt_summary.append( sum_thread % numthread )
    if hostrc:
        host_str = ', '.join(['%(host)s (%(cpu)d)' % hostrc.GetConfig(h) \
                            for h in hostrc.get_all_connected_hosts()])
        txt_summary.append( sum_rc % host_str )
    txt_summary.append('')
    text_summary = os.linesep.join(txt_summary)
    print(text_summary)

    # change directory before running sub-execution (reptrav will be deleted !)
    os.chdir(run['rep_trav'])

    # ----- Execute tests in parallel using a Dispatcher object
    # elementary task...
    task = DistribTestTask(#IN
                          run=run, prof=prof, conf=conf,
                          hostrc=hostrc,
                          nbmaxitem=0, timeout=timeout,
                          REPREF=REPREF, reptest=reptest, resutest=resutest, flashdir=flashdir,
                          nbmaxnook=nbmaxnook, cpresok=cpresok, facmtps=facmtps,
                          reptrav=reptrav,
                          info=1,
                          # OUT
                          nbnook=[0,]*numthread, test_result=[])
    # ... and dispatch task on 'list_tests'
    tit = _('Tests execution')
    run.timer.Start(tit)
    couples = list(zip(list_tests, [None]*nbtest))
    astout = Dispatcher(couples, task, numthread=numthread)
    run.DBG(astout.report())
    tot_dt = run.timer.StopAndGet(tit)[2]

    # Summary
    run.Mess(_('Summary of the run'), 'TITLE')
    print(text_summary)
    print(sum_end % now())
    t = [0., 0., 0., 0.]
    print(fmt_head)
    print(fmt_tot)
    dict_resu = {
        '__global__' : {
            'astest_dir' : reptest,
            's_astest_dir' : ', '.join(reptest),
            'nbtest'     : len(task.test_result),
            'err_all'    : sum(task.nbnook),
            'err_noresu' : 0,
            'err_vers'   : 0,
            'version'    : version_number,
        }
    }
    task.test_result.sort()
    for result in task.test_result:
        lin = result[:-1]
        del lin[1] # job, opts, diag, tcpu, tsys, ttot, telap, output
        t[0] += lin[2]
        t[1] += lin[3]
        t[2] += lin[4]
        t[3] += lin[5]
        print(fmt_resu % tuple(lin))
        dict_resu[lin[0]] = {
            'test'  : lin[0],
            'diag'  : lin[1],
            'tcpu'  : lin[2],
            'tsys'  : lin[3],
            'ttot'  : lin[4],
            'vers'  : repr_vers(version_number),
        }
    print(fmt_tot)
    print(fmt_res2 % (len(task.test_result), sum(task.nbnook), t[0], t[1], t[2], t[3]))

    # write diag.pick
    if prof['diag_pickled'][0] != '':
        with open(prof['diag_pickled'][0], 'wb') as pick:
            pickle.dump(dict_resu, pick)

    # check the number of tests really run
    if len(task.test_result) != len(list_tests):
        run.Mess(_('%d test-cases to run, %d really run !') \
            % (len(list_tests), len(task.test_result)), '<E>_ERROR')

    # force global diagnostic to <F>_ERROR if errors occured
    if sum(task.nbnook) > 0:
        run.diag = '<E>_ERROR'

    spup = 0.
    if tot_dt != 0.:
        spup = t[3]/tot_dt
    print(fmt_spup % spup)
    if hostrc is not None:
        print(os.linesep + hostrc.repr_history())

    run.CheckOK()
    run.Mess(_('All tests run successfully'), 'OK')
