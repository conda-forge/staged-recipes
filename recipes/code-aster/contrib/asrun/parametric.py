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
Functions for parametric executions
"""

import os
import os.path as osp
from math import log10

from asrun.common.i18n  import _
from asrun.mystring     import ufmt, cleanCR
from asrun.thread       import Dispatcher
from asrun.distrib      import DistribParametricTask
from asrun.common_func  import get_tmpname
from asrun.repart       import get_hostrc
from asrun.common.utils import now



fmt_head = '%s %s %s %s %s %s' % (_("job").center(12), _("result").center(18),
        _("cpu").rjust(8), _("sys").rjust(8), _("cpu+sys").rjust(8), _("elapsed").rjust(8) )
fmt_resu = '%-12s %-18s %8.2f %8.2f %8.2f %8.2f'
fmt_res2 = '%%4d %s %%4d %s    %%8.2f %%8.2f %%8.2f %%8.2f' \
    % (_("jobs").ljust(7), _("errors").ljust(10))
fmt_tot = '-'*12+' '+'-'*18+' '+'-'*8+' '+'-'*8+' '+'-'*8+' '+'-'*8


def Parametric(run, prof, runner, numthread='auto', **kargs):
    """Run a parametric study.
    """
    run.print_timer = True

    # 1. ----- initializations
    jn = run['num_job']

    # 1.2. rep_trav from profile or from run[...]
    reptrav = runner.reptrav()

    run.Mess(_('Code_Aster parametric execution'), 'TITLE')
    runner.set_cpuinfo(1, 1)

    # ----- how many threads ?
    try:
        numthread = int(numthread)
    except (TypeError, ValueError):
        numthread = run.GetCpuInfo('numthread')

    # 1.3. content of the profile
    if not prof.Get('D', typ='distr'):
        run.Mess(_('"distr" file is necessary'), '<F>_FILE_NOT_FOUND')
    else:
        fdist = prof.Get('D', typ='distr')[0]['path']
        if run.IsRemote(fdist):
            tmpdist = get_tmpname(run, run['tmp_user'], basename='distr')
            run.ToDelete(tmpdist)
            kret = run.Copy(tmpdist, fdist)
            fdist = tmpdist
        else:
            fdist = run.PathOnly(fdist)
    with open(fdist, 'r') as f:
        dist_cnt = f.read()
    try:
        keywords = get_distribution_data(cleanCR(dist_cnt))
    except Exception as msg:
        run.Mess(_("Error in the distr file: {0}").format(str(msg)), '<F>_ERROR')
    list_val = keywords['VALE']
    nbval = len(list_val)
    # it may be very big
    del keywords['VALE']

    if not prof.Get('R', typ='repe'):
        run.Mess(_('no result directory found (type "repe")'), '<F>_NO_RESU_DIR')
    else:
        resudir = prof.Get('R', typ='repe')[0]['path']
        if run.IsRemote(resudir):
            run.Mess(_('the result directory must not be on a remote host'), '<F>_ERROR')
        resudir = run.PathOnly(resudir)
        run.MkDir(resudir)
        run.Delete(osp.join(resudir, 'RESULTAT'))
        run.Delete(osp.join(resudir, 'NOOK'))
        flashdir = osp.join(resudir, 'flash')
        prfl = prof.Get('R', typ='flash')
        if prfl:
            if prfl[0]['path'] == "None":
                flashdir = None
            else:
                flashdir = prfl[0]['path']

    # check
    type_base, compress = prof.get_base('R')
    if type_base:
        path = prof.Get('R', typ=type_base)[0]['path']
        if path != resudir:
            run.Mess(ufmt(_("'repe' and '%s' must be identical. '%s' is set to %s"),
                          type_base, type_base, resudir), "<A>_ALARM")

    # get hostrc object
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
        timeout = prof.get_timeout() * 2.
    except Exception as reason:
        run.Mess(_("incorrect value for tpsjob : %s") % reason, '<F>_INVALID_PARAMETER')

    # print a summary
    summary = _("""
--- %d calculations to run
--- Run started at %s
--- Parameters used for this run :
    Directory to copy results       : %s
    Directory for job files         : %s
    Code_Aster version              : %s
    Executable filename             : %s
    Commands catalogue directory    : %s
    Elements catalogue filename     : %s
    Working directory               : %s
    Submission timeout (seconds)    : %.0f""")

    sum_thread = _("""    Number of threads               : %d""")
    sum_rc     = _("""    Available hosts (number of cpu) : %s""")
    sum_end = _("""
--- All executions finished at %s

--- Results :
""")
    fmt_spup = _("""
--- Speed-up is %.2f
""")
    info_start = ( nbval, now(), resudir, flashdir,
        prof.get_version_path(), kargs['exe'], kargs['cmde'], kargs['ele'],
        reptrav, timeout )
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
    if nbval < 1:
        run.Mess(_("There is no value for the parameters."), '<F>_ERROR')

    # change directory before running sub-execution (reptrav will be deleted !)
    os.chdir(run['rep_trav'])

    # ----- Execute calculations in parallel using a Dispatcher object
    # elementary task...
    task = DistribParametricTask( # IN
                          run=run, prof=prof,
                          hostrc=hostrc,
                          keywords=keywords,
                          nbmaxitem=0, timeout=timeout,
                          resudir=resudir, flashdir=flashdir,
                          reptrav=reptrav,
                          info=1,
                          # OUT
                          nbnook=[0,]*numthread, exec_result=[])
    # ... and dispatch task on 'list_tests'
    tit = _('Parametric execution')
    run.timer.Start(tit)
    etiq = 'calc_%%0%dd' % (int(log10(nbval)) + 1)
    labels = [etiq % (i+1) for i in range(nbval)]
    couples = list(zip(labels, list_val))
    execution = Dispatcher(couples, task, numthread=numthread)
    cpu_dt, sys_dt, tot_dt = run.timer.StopAndGet(tit)

    # Summary
    run.Mess(_('Summary of the run'), 'TITLE')
    print(text_summary)
    print(sum_end % now())
    t = [0., 0., 0., 0.]
    print(fmt_head)
    print(fmt_tot)
    task.exec_result.sort()
    for result in task.exec_result:
        lin = result[:-1]
        del lin[1] # job, opts, diag, tcpu, tsys, ttot, telap, output
        t[0] += lin[2]
        t[1] += lin[3]
        t[2] += lin[4]
        t[3] += lin[5]
        print(fmt_resu % tuple(lin))
    print(fmt_tot)
    print(fmt_res2 % (len(task.exec_result), sum(task.nbnook), t[0], t[1], t[2], t[3]))

    # check the number of calculations really run
    if len(task.exec_result) != len(list_val):
        run.Mess(_('%d studies to run, %d really run !') \
            % (len(list_val), len(task.exec_result)), '<E>_ERROR')

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
    run.Mess(_('All calculations run successfully'), 'OK')


def get_distribution_data(txt):
    """Return a dict of the distribution datas :
        (required)  VALE : list of dicts of the parameters values
        (optional) PRE_CALCUL (resp. UNITE_PRE_CALCUL) : list of commands to insert
            just after the DEBUT/POURSUITE command (respectively an integer defining
            the logical unit provided to INCLUDE)
        (optional) POST_CALCUL (resp. UNITE_POST_CALCUL) : list of commands to
            insert just before the FIN command (respectively an integer defining the
            logical unit provided to INCLUDE)
    """
    from asrun.N__F import _F
    dico = {}
    d = locals().copy()
    key = set(d.keys())
    exec(txt, d)
    if d.get('VALE') != None:
        dico['VALE'] = d['VALE']
    else:
        # sinon unique objet présent
        del d['__builtins__']
        key.symmetric_difference_update(list(d.keys()))
        if len(key) != 1:
            dico['VALE'] = []
        else:
            dico['VALE'] = d[key.pop()]
    if not is_list_of_dict(dico['VALE']):
        raise TypeError(_('a list of dicts is required, not %s') % dico['VALE'])
    for key in ('PRE_CALCUL', 'UNITE_PRE_CALCUL', 'POST_CALCUL', 'UNITE_POST_CALCUL'):
        dico[key] = d.get(key)
    return dico


def is_list_of_dict(obj):
    """Return True if obj is a list (iterable) of dictionnaries (with items method).
    """
    try:
        for sobj in obj:
            for k, v in list(sobj.items()):
                pass
        res = True
    except:
        res = False
    return res
