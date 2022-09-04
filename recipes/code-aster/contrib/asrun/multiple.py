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
Functions for multiple executions
"""

import os
import os.path as osp
import time

from asrun.common.i18n  import _
from asrun.mystring     import ufmt, add_to_tail, indent
from asrun.thread       import Dispatcher
from asrun.repart       import ResourceManager
from asrun.common.utils import now, version2tuple, YES_VALUES
from asrun.common.sysutils import local_host, same_hosts, short_hostname
from asrun.distrib      import DistributionTask
from asrun.client       import (
    ClientConfig,
    AsterCalcHdlrMulti,
    SERVER_CONF,
    MULTIDIR,
)


fmt_head = '%s %s %s %s %s %s' % (_("job").center(12), _("result").center(18),
        _("cpu").rjust(8), _("sys").rjust(8), _("cpu+sys").rjust(8), _("elapsed").rjust(8) )
fmt_resu = '%-12s %-18s %8.2f %8.2f %8.2f %8.2f'
fmt_res2 = '%%4d %s %%4d %s    %%8.2f %%8.2f %%8.2f %%8.2f' \
    % (_("jobs").ljust(7), _("errors").ljust(10))
fmt_tot = '-'*12+' '+'-'*18+' '+'-'*8+' '+'-'*8+' '+'-'*8+' '+'-'*8


class DistribMultipleTask(DistributionTask):
    """Manage several Code_Aster executions.
    items are couples (username, hostname)
    attributes (init during instanciation) :
    IN :
        run      : AsterRun object
        hostrc   : ResourceManager object
        prof     : AsterProfil object
        info     : information level
    OUT :
        nbnook (indiced by threadid)
        exec_result : list of (label, params, diag, tcpu, tsys, ttot, telap)
    """
    # declare attrs
    exec_result = keywords = resudir = result_on_client = None

    def _mess_timeout(self, dt, timeout, job, refused):
        """Emit a message when submission timeout occurs."""
        self.run.Mess(ufmt(_("no submission for last %.0f s " \
            "(timeout %.0f s, equal to 2 * the time requested by the main job), " \
            "job '%s' cancelled after %d attempts."), dt, timeout, job, refused))

    def _mess_running_timeout(self, dt, timeout, job):
        """Emit a message when running timeout occured."""
        self.run.Mess(ufmt(_("The job '%s' has been submitted since %.0f s and is "\
            "not ended (timeout %.0f s, equal to 4 * the time asked for the main job). " \
            "You can kill it and get other results or wait again..."),
            job, dt, timeout))

    def create_calcul(self, job, opts, itemid, pid):
        """Create a (derived) instance of AsterCalcul.
        """
        cfg = opts.copy()
        cfg['result_on_client'] = self.result_on_client
        calcul = AsterCalcHdlrMulti(self.run, job, prof=self.prof,
                                     pid=pid, config=cfg)
        return calcul


    def get_calcul_state(self, calcul):
        """Function to retreive the state of a calculation."""
        etat, diag, output = calcul.tail(nbline=5)
        if etat != 'ENDED':
            self.run.Mess(ufmt(_("job status is %-6s on %s"), etat, calcul.host), 'SILENT')
            txt = [line for line in output.splitlines() \
                if line.strip() != '' and (not line.strip().startswith('JOB=')) \
                and (not line.strip().startswith('<INFO>')) ]
            txt = os.linesep.join(txt).strip()
            if etat != 'PEND' and txt != '':
                txt = indent(txt, "%s: " % calcul.host)
                add_to_tail(self.reptrav, txt)
                print(txt)
            etat = calcul.get_state()[0]
        if not calcul.is_ended():
            dt = time.time() - calcul.start_time
            if dt > self.run_timeout > 0:
                self._mess_running_timeout(dt, self.run_timeout, calcul.name)
        return etat


    def get_calcul_diag(self, calcul):
        """Function to retreive the diagnostic of the calculation."""
        res = calcul.get_diag()
        return res


    def ended(self, job, opts, itemid, calcul, res):
        """Call when a job is ended.
        """
        line = self.summary_line(job, opts, res)
        print(line)
        add_to_tail(self.reptrav, line)
        # count nook for each thread
        gravity = self.run.GetGrav(calcul.diag)
        if gravity == -9 or gravity >= self.run.GetGrav('NOOK'):
            self.nbnook[opts['threadid']] += 1
        output_filename = _('no error or flashdir not defined')
        # copy output/error to flashdir
        fflash = calcul.copy_flash()
        output_filename = fflash['output'].repr()
        result = [job, opts]
        result.extend(res)
        result.append(output_filename)
        # clean flasheur
        calcul.kill()
        return result


    def result(self, *l_resu, **kwargs):
        """Function called after each task to treat results of execute.
        Arguments are 'execute' results + keywords args.
        'result' is called thread-safely, so can store results in attributes.
        """
        nf = len(self.exec_result)
        self.exec_result.extend(l_resu)
        for job, opts, diag, tcpu, tsys, ttot, telap, output in l_resu:
            nf += 1
            if self.info >= 2:
                self.run.Mess(ufmt(_('%s completed (%d/%d), diagnostic : %s'),
                        job, nf, self.nbitem, diag), 'SILENT')


def Multiple(run, prof, runner, numthread='auto'):
    """Run a multiple execution.
    """
    run.print_timer = True

    # 1. ----- initializations
    jn = run['num_job']

    # 1.2. rep_trav from profile or from run[...]
    reptrav = runner.reptrav()

    run.Mess(_('Code_Aster multiple execution'), 'TITLE')
    runner.set_cpuinfo(1, 1)

    # ----- how many threads ?
    try:
        numthread = int(numthread)
    except (TypeError, ValueError):
        numthread = run.GetCpuInfo('numthread')

    # 1.3. content of the profile
    serv_list = prof['multiple_server_list'][0]
    if not serv_list:
        run.Mess(_('List of servers ("multiple_server_list" parameter) not found'),
                 '<F>_ERROR')
    serv_list = serv_list.split()
    nbval = len(serv_list)
    # tell if results have to be transfered on the client server
    # or let on each host.
    result_on_client = prof['multiple_result_on_client'][0] in YES_VALUES

    # this hostrc object is only used to check the hosts availability
    tit = _("Checking hosts")
    run.timer.Start(tit)
    client = ClientConfig(run.rcdir)
    client.init_server_config()
    avail_servers = client.get_server_list()
    dhost = {}
    couples = []
    for sname in serv_list:
        found = False
        for label in avail_servers:
            cfg = client.get_server_config(label)
            if same_hosts(sname, cfg['nom_complet']):
                found = True
                client.refresh_server_config([label])
                cfg = client.get_server_config(label)
                if version2tuple(cfg['asrun_vers']) >= (1, 9, 2):
                    couples.append( (short_hostname(sname), cfg) )
                    dhost[sname] = { 'user' : cfg['login'] }
                else:
                    run.Mess(ufmt(_("Version 1.9.2 or newer is required to run " \
                        "multiple executions. It is %s on %s (installed in %s)."),
                        cfg['asrun_vers'], label, cfg['rep_serv']), '<E>_ERROR')
                break
        if not found:
            run.Mess(ufmt(_("Host '%s' is not available in %s."), sname,
                          client.rcfile(SERVER_CONF)), "<E>_ERROR")
    run.DBG("couples :", couples, all=True)

    hostrc = ResourceManager(dhost)
    n_avail, n_tot = hostrc.CheckHosts(run, numthread=numthread)
    run.timer.Stop(tit)
    run.Mess(_('Number of available hosts : %d/%d') % (n_avail, n_tot), "SILENT")
    if n_avail < 1:
        run.Mess(_("No available host. Run cancelled."), "<F>_ERROR")
    if n_avail < len(serv_list):
        run.Mess(_("All the hosts are not available. Run cancelled."), "<F>_ERROR")

    # define a hostrc object to allow a lot of simultaneous executions
    hostinfo = { local_host : { 'mem' : 999999, 'cpu' : 999999 }}
    hostrc = ResourceManager(hostinfo)

    #XXX tpsjob : max elapsed time ?
    try:
        timeout = prof.get_timeout() * 2.
    except Exception as reason:
        run.Mess(_("incorrect value for tpsjob : %s") % reason, '<F>_INVALID_PARAMETER')

    # print a summary
    summary = _("""
--- Profile executed on %2d servers   : %s
--- Run started at %s
--- Parameters used for this run :
    Code_Aster version               : %s
    Results directory                : %s
    Submission timeout (seconds)     : %.0f""")

    sum_thread = _("""    Number of threads                : %d""")
    sum_end = _("""
--- All executions finished at %s

--- Results :
""")
    jobname = prof['nomjob'][0]
    ldir = ", ".join(["%s/%s_%s" % (MULTIDIR, jobname, val[0]) for val in couples])
    if result_on_client:
        ldir = osp.expandvars(ldir)
    else:
        ldir = "(" + _("on each host") + ") " + ldir
    info_start = ( nbval, ", ".join(serv_list), now(),
        prof.get_version_path(), ldir, timeout )
    txt_summary = [ ufmt(summary, *info_start), ]
    if numthread > 1:
        txt_summary.append( sum_thread % numthread )
    txt_summary.append('')
    text_summary = os.linesep.join(txt_summary)
    print(text_summary)

    # ----- Execute calcutions in parallel using a Dispatcher object
    # elementary task...
    task = DistribMultipleTask( # IN
                          run=run, prof=prof,
                          hostrc=hostrc,
                          nbmaxitem=0,
                          timeout=timeout, run_timeout=2. * timeout,
                          reptrav=reptrav,
                          result_on_client=result_on_client,
                          info=1,
                          # OUT
                          nbnook=[0,]*numthread, exec_result=[])
    # ... and dispatch task on 'serv_list'
    tit = _('Multiple execution')
    run.timer.Start(tit)
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
    if len(task.exec_result) != len(couples):
        run.Mess(_('%d studies to run, %d really run !') \
            % (len(couples), len(task.exec_result)), '<E>_ERROR')

    # force global diagnostic to <F>_ERROR if errors occured
    if sum(task.nbnook) > 0:
        run.diag = '<E>_ERROR'

    if hostrc is not None:
        print(os.linesep + hostrc.repr_history())

    run.CheckOK()
    run.Mess(_('All calculations run successfully'), 'OK')
