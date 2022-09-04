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
    Module pour la distribution de calcul.
"""

import os.path as osp
import time

from asrun.common.i18n import _
from asrun.mystring  import ufmt, add_to_tail
from asrun.calcul    import AsterCalcTestcase, AsterCalcParametric
from asrun.thread    import Task, TaskAbort, Empty, Lock
from asrun.repart    import NORESOURCE, ALLOCATED, OVERLIMIT
# import keep for compatibility ?
from asrun.common.utils import force_list, force_couple

fmt_resu = '%-12s %-21s %8.2f %8.2f %8.2f'
fmt_resu_numb = '%-12s %-10s %-21s %8.2f %8.2f %8.2f %8.2f'
FAILURE = object()

def check_opts(obj):
    """Check that values have the expected interface."""
    if obj is None:
        obj = {}
    elif   hasattr(obj, '__getitem__') \
        and hasattr(obj, '__setitem__') \
        and hasattr(obj, 'get'):
        pass
    else:
        raise TypeError('"opts" invalid')
    return obj


#-------------------------------------------------------------------------------
# Remember : the same Task instance is dispatched on all threads
#-------------------------------------------------------------------------------
class DistributionTask(Task):
    """Manage executions of several Code_Aster executions.
    items are couples (jobname, dict_options)

    attributes (initialized during instanciation) :
        run     : AsterRun object
        hostrc  : ResourceManager object
        timeout : timeout for not allocated jobs
        info    : information level
    """
    # Warning: do not change required parameters of DistribParametricTask
    #          without updating MACR_RECAL source files.
    last_submit = -1.
    # declare attrs
    run = hostrc = prof = conf = test_result = None
    info = nbitem = timeout = run_timeout = nbnook = nbmaxnook = 0
    facmtps = 0.
    cpresok = False
    REPREF = reptest = resutest = flashdir = reptrav = ""

    def __init__(self, **kwargs):
        """Initialization"""
        Task.__init__(self, **kwargs)
        # class attrs should be here!
        self._ended_lock = Lock()

    def _mess_timeout(self, dt, timeout, job, refused):
        """Emit a message when submission timeout occurs."""
        self.run.Mess(ufmt(_("no submission for last %.0f s (timeout %.0f s), job '%s' " \
            "cancelled after %d attempts."), dt, timeout, job, refused))

    def _mess_running_timeout(self, dt, timeout, job):
        """Emit a message when running timeout occured."""
        self.run.Mess(ufmt(_("The job '%s' has been submitted since %.0f s and is "\
            "not ended (timeout %.0f s). You can kill it and get other results."),
            job, dt, timeout))

    def execute(self, items, **kwargs):
        """Function called for each group of items of the stack.
        """
        assert type(items) in (list, tuple) and len(items) == 0, 'nbmaxitem should be null'
        assert self.hostrc is not None, 'ResourceManager is needed'

        ended = False
        sum_elaps = 0.
        refused_delay = 0.
        refresh_delay = 0.
        run_calc = []
        l_resu = []
        while not ended:
            moy_elaps = sum_elaps / max(1, len(l_resu))
            refresh_delay = max(2., moy_elaps/10.)
            self.pre_exec(result=l_resu, **kwargs)

            # 1. try to start a new calculation
            rc_ok = True
            while rc_ok:
                try:
                    itemid, item = self.queue_get()
                    queue_is_empty = False
                except Empty:
                    queue_is_empty = True
                    rc_ok = False
                if not queue_is_empty:
                    if refused_delay > 0.:
                        self.run.DBG('waiting for %s s before requesting new resources...' \
                            % refused_delay)
                        time.sleep(refused_delay)
                    refused_delay = 0.
                    job, opts = item
                    opts = check_opts(opts)
                    opts['threadid'] = kwargs['threadid']
                    pid = self.run.get_pid(itemid)
                    calcul = self.create_calcul(job, opts, itemid, pid)
                    # request resources
                    serv, host = None, None
                    status = ALLOCATED
                    if self.hostrc is not None:
                        host, status = self.hostrc.Request(run=self.run, nomjob=job,
                                                           cpu = calcul.request('cpu'),
                                                           mem = calcul.request('mem'))
                    rc_ok = status == ALLOCATED
                    result = None
                    if not rc_ok:
                        # not enough resource available
                        result = self.refused(job, opts, itemid, status)
                        refused_delay = max(2., moy_elaps/5.)
                    else:
                        refresh_delay = 0.
                        if self.hostrc is not None:
                            serv = self.hostrc.GetConfig(host).get('serv')
                        order = self.is_done(job)
                        calcul.on_host(serv, host)
                        jret, out = calcul.start()
                        self.last_submit = time.time()
                        if jret != 0:
                            result = self.start_failed(job, opts, itemid, msg=out)
                            if self.hostrc is not None:
                                self.hostrc.Free(job)
                        else:
                            if self.info >= 1:
                                host = host or "'localhost'"
                                self.run.Mess(ufmt(_('Starting execution of %s on %s (%d/%d - %s/%s)...'),
                                    job, host, order, self.nbitem, calcul.jobid, calcul.queue),
                                    'SILENT')
                            self.run.DBG('Starting execution // thread #%d   %s   %s   %s' \
                                    % (kwargs['threadid'], job, calcul.jobid, calcul.queue))
                            opts['submit_time'] = self.last_submit
                            opts['order'] = order
                            run_calc.append([job, opts, itemid, calcul])
                    if result is FAILURE:
                        result = self.failure(job, opts, itemid)
                        l_resu.append(result)

            # 2. get calculation state
            next = []
            if refresh_delay > 0.:
                self.run.DBG('waiting for %s s for refreshing state of jobs...' % refresh_delay)
                time.sleep(refresh_delay)
            for job, opts, itemid, calcul in run_calc:
                actu_time = time.time()
                state = self.get_calcul_state(calcul)
                # wait at least 3 secondes between submission and end
                if state == 'ENDED' and actu_time - opts['submit_time'] > 3.:
                    if self.hostrc is not None:
                        self.hostrc.Free(job)
                    res = list(self.get_calcul_diag(calcul))
                    result = self._ended_thread(job, opts, itemid, calcul, res)
                    sum_elaps += result[6]
                    l_resu.append(result)
                else:
                    self.run.DBG("waiting for %s : state %s" % (job, state))
                    next.append([job, opts, itemid, calcul])
            all_finished = len(next) == 0
            run_calc = next

            self.post_exec(**kwargs)
            ended = queue_is_empty and all_finished

        return l_resu

    def failure(self, job, opts, itemid):
        """Count failure as NOOK like an error at execution."""
        self.nbnook[opts['threadid']] += 1
        res = ['<F>_NOT_RUN', 0., 0., 0., 0.]
        result = [job, opts]
        result.extend(res)
        line = self.summary_line(job, opts, res)
        add_to_tail(self.resutest, line, filename='NOOK')
        add_to_tail(self.resutest, line, filename='RESULTAT')
        result.append('failure')
        return result

    def refused(self, job, opts, itemid, status):
        """Action when a job is refused.
        """
        opts['refused'] =  opts.get('refused', 0) + 1
        result = FAILURE
        if   status == OVERLIMIT:
            self.run.Mess(ufmt(_("job '%s' exceeds resources limit (defined through "
                "hostfile), it will not be submitted."), job), '<A>_LIMIT_EXCEEDED')
        elif status == NORESOURCE:
            if self.last_submit > 0.:
                dt = time.time() - self.last_submit
            else:
                dt = 0.01
            if self.info >= 2 :
                self.run.Mess(ufmt(_("'%s' no resource available (attempt #%d, " \
                                      "no submission for %.1f s)."), job, opts['refused'], dt))
            # try another time
            if 0. < dt < self.timeout:
                self.queue_put((job, opts))
                result = None
            else:
                self._mess_timeout(dt, self.timeout, job, opts['refused'])
        return result

    def start_failed(self, job, opts, itemid, msg):
        """Action when a job submitting failed. """
        self.run.Mess(ufmt(_("'%s' not submitted. Error : %s"), job, msg), '<A>_NOT_SUBMITTED')
        return FAILURE

    def get_calcul_state(self, calcul):
        """Function to retreive the state of a calculation."""
        res = calcul.get_state()
        if not calcul.is_ended():
            dt = time.time() - calcul.start_time
            if dt > self.run_timeout > 0:
                self._mess_running_timeout(dt, self.run_timeout, calcul.name)
        return res[0]

    def get_calcul_diag(self, calcul):
        """Function to retreive the diagnostic of the calculation."""
        res = calcul.get_diag()
        return res

    def pre_exec(self, **kwargs):
        """Function called at the beginning of execute. """

    def post_exec(self, **kwargs):
        """Function called at the end of execute."""

    def create_calcul(self, job, opts, itemid, pid):
        """Create a (derived) instance of AsterCalcul. """
        raise NotImplementedError

    def summary_line(self, job, opts, res, compatibility=False):
        """Return a summary line of the execution result."""
        args = [job, ]
        fmt = fmt_resu
        expect = 5
        if compatibility:
            args.append('(%d/%d)' % (opts.get('order', 0), self.nbitem))
            fmt = fmt_resu_numb
            expect += 2
        else:
            res = res[:-1]
        args.extend(res)
        if len(args) == expect:
            line = ufmt(fmt, *args)
        else:
            line = '%s : can not write the summary line' % job
        return line

    def _ended_thread(self, *args):
        """Call 'ended' method thread safely"""
        self._ended_lock.acquire()
        result = self.ended(*args)
        self._ended_lock.release()
        return result

    # failure, ended should return result in the same format
    def ended(self, job, opts, itemid, calcul, res):
        """Call when a job is ended."""
        raise NotImplementedError

    def result(self, *l_resu, **kwargs):
        """Function called after each task to treat results of execute.
        Arguments are 'execute' results + keywords args.
        'result' is called thread-safely, so can store results in attributes."""
        raise NotImplementedError


class DistribTestTask(DistributionTask):
    """Manage executions of several Code_Aster testcases.
    items are couples (jobname=testcase name, options)
    attributes (init during instanciation) :
    IN :
        run      : AsterRun object
        hostrc   : ResourceManager object
        prof     : AsterProfil object
        conf     : AsterConfig object
        REPREF, reptest, resutest : directories
        flashdir : directory for .o, .e files...
        nbmaxnook, cpresok, facmtps : parameters
        reptrav  : working directory
        info     : information level
    OUT :
        nbnook (indiced by threadid)
        test_result : list of (test, opts, diag, tcpu, tsys, ttot, telap)
    """
    def _mess_timeout(self, dt, timeout, job, refused):
        """Emit a message when submission timeout occurs."""
        self.run.Mess(ufmt(_("no submission for last %.0f s " \
            "(timeout %.0f s, equal to the time requested by the main job, named 'astout'), " \
            "job '%s' cancelled after %d attempts."), dt, timeout, job, refused))

    def pre_exec(self, **kwargs):
        """Function called at the beginning of execute.
        """
        if sum(self.nbnook) >= self.nbmaxnook:
            reason = ufmt(_('Maximum number of errors reached : %d (%d errors, per thread : %s)'),
                        self.nbmaxnook, sum(self.nbnook), ', '.join([str(n) for n in self.nbnook]))
            current_result = kwargs['result']
            raise TaskAbort(reason, current_result)

    def create_calcul(self, job, opts, itemid, pid):
        """Create a (derived) instance of AsterCalcul.
        """
        calcul = AsterCalcTestcase(self.run, test=job, prof=self.prof, pid=pid,
                                   conf=self.conf, REPREF=self.REPREF,
                                   reptest=self.reptest, resutest=self.resutest,
                                   facmtps=self.facmtps)
        return calcul

    def ended(self, job, opts, itemid, calcul, res):
        """Call when a job is ended.
        """
        line = self.summary_line(job, opts, res)
        # printing line is not thread safe but it's only printing!
        print(line)
        add_to_tail(self.reptrav, line)
        # count nook for each thread
        gravity = self.run.GetGrav(calcul.diag)
        error = gravity == -9 or gravity >= self.run.GetGrav('NOOK')
        if error:
            self.nbnook[opts['threadid']] += 1
            add_to_tail(self.resutest, line, filename='NOOK')
        add_to_tail(self.resutest, line, filename='RESULTAT')
        output_filename = _('no error or flashdir not defined')
        # keep result files if RESOK or test failed
        if self.cpresok == 'RESNOOK' and not error:
            calcul.clean_results()
        else:
            # copy output/error to flashdir
            if self.flashdir != None:
                try:
                    if not osp.isdir(self.flashdir):
                        self.run.MkDir(self.flashdir, niverr='SILENT')
                except OSError:
                    pass
                self.run.Copy(self.flashdir,
                          calcul.flash('output'), calcul.flash('error'), calcul.flash('export'),
                          niverr='<A>_ALARM')
                output_filename = osp.join(self.flashdir, osp.basename(calcul.flash('output')))
        result = [job, opts]
        result.extend(res)
        result.append(output_filename)
        # clean flasheur
        calcul.kill()
        return result

    def result(self, *l_resu, **kwargs):
        """Function called after each task to treat results of 'execute'.
        Arguments are 'execute' results + keywords args.
        'result' is called thread-safely, so can store results in attributes.
        """
        nf = len(self.test_result)
        self.test_result.extend(l_resu)
        for values in l_resu:
            job, diag = values[0], values[2]
            nf += 1
            if self.info >= 2:
                self.run.Mess(ufmt(_('%s completed (%d/%d), diagnostic : %s'),
                        job, nf, self.nbitem, diag), 'SILENT')


class DistribParametricTask(DistributionTask):
    """Manage several Code_Aster executions.
    items are couples (jobname=label, parameters values)
    attributes (init during instanciation) :
    IN :
        run      : AsterRun object
        hostrc   : ResourceManager object
        prof     : AsterProfil object
        resudir  : directories
        flashdir : directory for .o, .e files...
        info     : information level
    OUT :
        nbnook (indiced by threadid)
        exec_result : list of (label, params, diag, tcpu, tsys, ttot, telap)
    """
    # declare attrs
    exec_result = keywords = resudir = None

    def _mess_timeout(self, dt, timeout, job, refused):
        """Emit a message when submission timeout occurs."""
        self.run.Mess(ufmt(_("no submission for last %.0f s " \
            "(timeout %.0f s, equal to 2 * the time requested by the main job), " \
            "job '%s' cancelled after %d attempts."), dt, timeout, job, refused))

    def create_calcul(self, job, opts, itemid, pid):
        """Create a (derived) instance of AsterCalcul.
        """
        calcul = AsterCalcParametric(self.run, job, prof=self.prof, pid=pid,
                                     values=opts, keywords=self.keywords,
                                     resudir=self.resudir)
        return calcul

    def ended(self, job, opts, itemid, calcul, res):
        """Call when a job is ended."""
        line = self.summary_line(job, opts, res)
        # printing line is not thread safe but it's only printing!
        print(line)
        add_to_tail(self.reptrav, line)
        # count nook for each thread
        gravity = self.run.GetGrav(calcul.diag)
        error = gravity == -9 or gravity >= self.run.GetGrav('NOOK')
        if error:
            self.nbnook[opts['threadid']] += 1
            add_to_tail(self.resudir, line, filename='NOOK')
        add_to_tail(self.resudir, line, filename='RESULTAT')
        output_filename = _('no error or flashdir not defined')
        # copy output/error to flashdir
        if self.flashdir != None:
            try:
                if not osp.isdir(self.flashdir):
                    self.run.MkDir(self.flashdir, niverr='SILENT')
            except OSError:
                pass
            self.run.Copy(self.flashdir,
                       calcul.flash('output'), calcul.flash('error'), calcul.flash('export'),
                       niverr='<A>_ALARM')
            output_filename = osp.join(self.flashdir, osp.basename(calcul.flash('output')))
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
        for values in l_resu:
            job, diag = values[0], values[2]
            nf += 1
            if self.info >= 2:
                self.run.Mess(ufmt(_('%s completed (%d/%d), diagnostic : %s'),
                        job, nf, self.nbitem, diag), 'SILENT')
