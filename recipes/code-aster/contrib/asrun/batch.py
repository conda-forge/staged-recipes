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
"Wrapper" to LSF, PBS, SunGE, Slurm batch schedulers.
Only for submit function yet.
"""
# All configuration parameters (taken in AsterRun object) should be
# overridden using AsterProfil object.

import math
import os
import os.path as osp
import re

from asrun.common.i18n import _
from asrun.common.sysutils import local_user
from asrun.common.utils import dhms2s
from asrun.common_func import get_tmpname
from asrun.mystring import ufmt
from asrun.status import JobInfo


class BatchError(Exception): pass

class BatchSystem(object):
    """Base class for a batch scheduler.
    Attributes :
        bsub : program to submit a job,
        bjob : program to get the list of jobs,
        bkil : program to cancel a job,
        bsig : program to send a signal to a job,
        bjid : environment variable containing the job id,
        cmdsub : command line to submit a job,
        cmdjob : command line to get the status of a job,
        cmdcpu : command line to get the cputime of a job (if cmdjob returns
                 the cputime too, let cmdcpu equal to None),
        cmdkil : command line to send a signal SIGKIL to a job.
        cmdsig : command line to send a signal to a job.
    Configuration parameters :
        batch_nom : to choose the scheduler class
        batch_ini : environment script (adjust PATH to find bsub and co)
        batch_queue_group & batch_queue_xxx : to define groups of queues.
    """
    bsub = bjob = bkil = bsig = bjid = None
    cmdsub = '%(bsub)s < %(btc_file)s'
    cmdjob = '%(bjob)s'
    cmdcpu = None
    cmdkil = '%(bkil)s %(jobid)s'
    cmdsig = None

    def __init__(self, run, prof):
        """Initialization
        run    : AsterRun object,
        prof   : AsterProfil object.
        """
        self.run    = run
        self.prof   = prof
        self.script = None
        self.change_input_script = False
        self.jn = os.getpid()
        self.btc_file = None
        if prof:
            self.btc_file = get_tmpname(self.run, self.run['tmp_user'],
                                    basename='btc_%s' % prof['nomjob'][0])

    def set_subpara(self, script, change_input_script=False):
        """Provide required parameters for submission.
        script : shell script to submit.
        """
        self.script = script
        self.change_input_script = change_input_script

    def config_dict(self):
        """Build dict infos from configuration."""
        dico = {
            'bsub'      : self.bsub,
            'bjob'      : self.bjob,
            'bkil'      : self.bkil,
            'bsig'      : self.bsig,
            'bjid'      : self.bjid,
            'batch_ini' : self.run.get('batch_ini', ''),
            'username'  : local_user,
        }
        return dico

    def build_dict_info(self):
        """Add infos into dict_info.
        """
        dico = self.config_dict().copy()
        dico.update({
            'nomjob'    : self.prof['nomjob'][0],
            'tpsjob'    : int(float(self.prof['tpsjob'][0])),    # in minutes
            'tpmax'     : self.prof.args.get('tpmax', 1),        # in seconds
            'memjob'    : int(float(self.prof['memjob'][0])),        # in kB
            'memjobMB'  : int(float(self.prof['memjob'][0]) / 1024), # in MB
            'clasgr'    : self.prof['classe'][0],
            'depart'    : self.prof['depart'][0],
            'after_job' : self.prof['after_job'][0],
            'mpi_nbcpu' : self.prof['mpi_nbcpu'][0],
            'mpi_nbnoeud': self.prof['mpi_nbnoeud'][0],
            'custom'    : self.prof['batch_custom'][0],
        })
        # number of mpi processes per node
        dico['cpu_per_node'] = int(math.ceil(
            float(self.prof['mpi_nbcpu'][0] or 1) /
            float(self.prof['mpi_nbnoeud'][0] or 1)))
        dico['batch_ini'] = self.prof['batch_ini'][0] or dico['batch_ini']
        dico['bsub'] = self.prof['batch_sub'][0] or dico['bsub']

        group = self.prof['batch_queue_group'][0] or self.run.get('batch_queue_group', '')
        if dico['clasgr'] != '' and dico['clasgr'] in group.split():
            dico['classe'] = self.prof['batch_queue_%s' % dico['clasgr']][0] or \
                             self.run.get('batch_queue_%s' % dico['clasgr'], '')
        dico['btc_file'] = self.btc_file
        self.dict_info = dico

    def change_script(self):
        """Add header to 'script' file.
        """
        if self.script is None or not osp.isfile(self.script):
            raise BatchError('file not found : %s' % self.script)
        with open(self.script, 'r') as f:
            txt = f.read()
        txt = txt.replace('%', '%%')
        lines = txt.splitlines()
        return lines

    def parse_output(self, output):
        """Extract jobid and queue from output of submission."""
        raise NotImplementedError("must be overridden in a subclass")

    def parse_jobstate_output(self, output, jobinf):
        """Extract informations about the job state."""
        raise NotImplementedError("must be overridden in a subclass")

    def parse_jobcpu(self, output, jobinf):
        """Extract informations about the job state."""
        raise NotImplementedError("must be overridden in a subclass")

    def supports_signal(self):
        """Tell if the scheduler knows to send a signal to a job."""
        return self.cmdsig is not None

    def submit(self):
        """Submit the script.
        Returns a tuple : (exitcode, jobid, queue)
        """
        cmd = ''
        if self.dict_info['batch_ini'] != '':
            cmd = '. %(batch_ini)s ; '
        cmd += self.cmdsub
        iret, out = self.run.Shell(cmd % self.dict_info)
        self.run.DBG('Output of submitting :', out, all=True)
        if iret != 0:
            self.run.Mess(ufmt(_('Failure during submitting. Error message :\n%s'), out),
                '<A>_ALARM')
            if osp.isfile(self.btc_file):
                with open(self.btc_file, 'r') as f:
                    self.run.DBG('submitted script :', f.read(), all=True)
        jobid, queue = self.parse_output(out)
        return iret, jobid, queue

    def start(self):
        """Go"""
        self.build_dict_info()
        txt = os.linesep.join(self.change_script())
        self.run.DBG('batch.start changed script :', txt, self.dict_info, all=True)
        content = txt % self.dict_info
        with open(self.btc_file, 'w') as f:
            f.write(content)
        iret, jobid, queue = self.submit()
        if self.change_input_script and os.access(self.script, os.W_OK):
            with open(self.script, 'w') as f:
                f.write(content)
        try:
            os.remove(self.btc_file)
        except OSError:
            pass
        return iret, jobid, queue

    def get_jobstate(self, jobid, jobname):
        """Return infos about this job :
        its state (PEND, RUN, SUSPENDED, ENDED),
        the node on and the queue in it is running,
        the cpu time spend.
        """
        jobinf = JobInfo()
        jobinf.jobid, jobinf.jobname = jobid, jobname
        dcfg = self.config_dict()
        dcfg.update(jobinf.dict_values())
        cmd = ''
        if dcfg['batch_ini'] != '':
            cmd = '. %(batch_ini)s ; '
        cmd += self.cmdjob
        cmd = cmd % dcfg
        iret, out = self.run.Shell(cmd)
        self.run.DBG('Output of job status :', out, all=True)
        if iret != 0:
            self.run.Mess(ufmt(_('Failure during retreiving job information. Error message :\n%s'), out),
                '<A>_ALARM')
            self.run.Mess(ufmt(_('Command line: %s'), cmd))
        jobinf = self.parse_jobstate_output(out, jobinf)
        if jobinf.state == 'RUN' and self.cmdcpu:
            cmd = ''
            if dcfg['batch_ini'] != '':
                cmd = '. %(batch_ini)s ; '
            cmd += self.cmdcpu
            cmd = cmd % dcfg
            iret, out = self.run.Shell(cmd)
            self.run.DBG('Output of job status (cpu) :', out, all=True)
            if iret != 0:
                self.run.Mess(ufmt(_('Failure during retreiving job cpu information. Error message :\n%s'), out),
                    '<A>_ALARM')
                self.run.Mess(ufmt(_('Command line: %s'), cmd))
            jobinf = self.parse_jobcpu(out, jobinf)
        return jobinf.as_func_actu_result()

    def signal_job(self, jobid, signal):
        """Send the given signal to the job."""
        if signal != 'KILL' and not self.supports_signal():
            self.run.Mess(_('Job scheduler does not know how to send a signal.'), '<A>_ALARM')
            return 4
        jobinf = JobInfo()
        jobinf.jobid = jobid
        dcfg = self.config_dict()
        dcfg.update(jobinf.dict_values())
        dcfg['signal'] = signal
        cmd = ''
        if dcfg['batch_ini'] != '':
            cmd = '. %(batch_ini)s ; '
        if signal == 'KILL':
            cmd += self.cmdkil
        else:
            cmd += self.cmdsig
        cmd = cmd % dcfg
        iret, out = self.run.Shell(cmd)
        self.run.DBG('Output of job kill :', out, all=True)
        if iret != 0:
            self.run.Mess(ufmt(_('Failure during killing a job. Error message :\n%s'), out),
                '<A>_ALARM')
            self.run.Mess(ufmt(_('Command line: %s'), cmd))
        return iret


class LSF(BatchSystem):
    """for LSF batch system."""
    bsub = 'bsub'
    bjob = 'bjobs'
    bkil = 'bkill'
    bsig = bkil
    bjid = 'LSB_JOBID'
    cmdsig = '%(bsig)s -s %(signal)s %(jobid)s'

    def build_dict_info(self):
        """Add infos into dict_info.
        """
        super(LSF, self).build_dict_info()
        self.dict_info.update({
            'error'     : osp.join(self.run['flasheur'], '%s.e%%J' % self.dict_info['nomjob']),
            'output'    : osp.join(self.run['flasheur'], '%s.o%%J' % self.dict_info['nomjob']),
        })

    def change_script(self):
        """Modify submission 'script' file.
        """
        txt = ["#BSUB -J %(nomjob)s",
             "#BSUB -W %(tpsjob)s",
             "#BSUB -M %(memjob)s",
             "#BSUB -e %(error)s",
             "#BSUB -o %(output)s"]
        if self.dict_info.get('mpi_nbcpu'):
            txt.append("#BSUB -n %(mpi_nbcpu)s")
        if self.dict_info.get('classe'):
            txt.append('''#BSUB -q "%(classe)s"''')
        if self.dict_info.get('depart'):
            txt.append("#BSUB -b %(depart)s")
        if self.dict_info.get('after_job'):
            txt.append("#BSUB -w ended(%(after_job)s)")
        if self.dict_info.get('custom'):
            txt.append("#BSUB %(custom)s")
        # core script
        core = super(LSF, self).change_script()
        txt.extend(core)
        return txt

    def parse_output(self, output):
        """Extract jobid and queue from output of submission.
        """
        mat = re.search(r'Job *<([^\s]+)> *is submitted to .*queue *<([^\s]+)>', output)
        jobid, queue = '', ''
        if mat is not None:
            jobid, queue = mat.groups()
        return jobid, queue

    def parse_jobstate_output(self, output, jobinf):
        """Extract informations about the job state.
        """
        mat = re.search('(^ *%s .*)$' % jobinf.jobid, output, re.MULTILINE)
        if mat == None:
            jobinf.state = "ENDED"
        else:
            lin = mat.group(1).split()
            if len(lin) >= 3:
                jobinf.state = lin[2]
                if jobinf.state != "PEND" and len(lin) >= 6:
                    jobinf.node = re.split('[*@]+', lin[5])[-1]
            if jobinf.state.find('SUSP')>-1:
                jobinf.state = 'SUSPENDED'
        return jobinf


class PBS(BatchSystem):
    """for PBS batch system.
    """
    bsub = 'qsub'
    bjob = 'qstat'
    bkil = 'qdel'
    bsig = bkil
    bjid = 'PBS_JOBID'
    cmdjob = '%(bjob)s -f %(jobid)s'
    _conv_state = {
        'R' : 'RUN', 'E'  :'RUN',
        'W' : 'PEND', 'T' : 'PEND', 'Q' : 'PEND',
        'S' : 'SUSPENDED', 'H' : 'SUSPENDED',
    }

    def build_dict_info(self):
        """Add infos into dict_info.
        """
        super(PBS, self).build_dict_info()
        # format of start time : [[MM]DD]HHmm
        self.dict_info['depart'] = self.dict_info['depart'].replace(':', '')

    def change_script(self):
        """Modify submission 'script' file.
        """
        core = super(PBS, self).change_script()
        txt = [core.pop(0),]
        txt.extend(["#PBS -N %(nomjob)s",
                    "#PBS -l walltime=%(tpmax)s",
                    "#PBS -l mem=%(memjob)skb",])
        # output/error will be named %(nomjob).o%(jobid) in the directory where qsub has been run
        if int(self.dict_info.get('mpi_nbnoeud') or 0) > 1:
            txt.append("#PBS -l nodes=%(mpi_nbnoeud)s:ppn=%(cpu_per_node)s")
        if self.dict_info.get('classe'):
            txt.append('''#PBS -q "%(classe)s"''')
        if self.dict_info.get('depart'):
            txt.append("#PBS -a %(depart)s")
        if self.dict_info.get('after_job'):
            txt.append("#PBS -W depend=after:%(after_job)s")
        if self.dict_info.get('custom'):
            txt.append("#PBS %(custom)s")
        # core script
        txt.extend(core)
        return txt

    def parse_output(self, output):
        """Extract jobid and queue from output of submission.
        """
        queue = 'unknown'
        jobid = output.split('.')[0]
        return jobid, queue

    def start(self):
        """Go"""
        prev = os.getcwd()
        os.chdir(self.run['flasheur'])
        iret, jobid, queue = super(PBS, self).start()
        os.chdir(prev)
        return iret, jobid, queue

    def parse_jobstate_output(self, output, jobinf):
        """Extract informations about the job state.
        """
        # job state
        metat = re.search(r' job_state *= *(\S+)', output, re.MULTILINE)
        if metat == None:
            jobinf.state = "ENDED"
        else:
            jobinf.state = self._conv_state.get(metat.group(1), '?')
        # queue
        mqueue = re.search(r' queue *= *(\S+)', output, re.MULTILINE)
        if mqueue != None:
            jobinf.queue = mqueue.group(1)
        # exec host
        mnode = re.search(r' exec_host *= *(\S+)/', output, re.MULTILINE)
        if mnode != None:
            jobinf.node = mnode.group(1)
        return jobinf


class PBS_NoSplitJobId(PBS):
    """for PBS batch system.
    """
    def parse_output(self, output):
        """Extract jobid and queue from output of submission.
        """
        return output, 'unknown'


class SGE(BatchSystem):
    """for Sun Grid Engine batch system.
    """
    bsub = 'qsub'
    bjid = 'JOB_ID'
    bjob = 'qstat'
    bkil = 'qdel'
    bsig = bkil
    cmdsub = '%(bsub)s -S /bin/sh < %(btc_file)s'
    cmdcpu = '%(bjob)s -j %(jobid)s'

    def build_dict_info(self):
        """Add infos into dict_info.
        """
        super(SGE, self).build_dict_info()
        self.dict_info.update({
            'error'     : osp.join(self.run['flasheur'], '%s.e$JOB_ID' % self.dict_info['nomjob']),
            'output'    : osp.join(self.run['flasheur'], '%s.o$JOB_ID' % self.dict_info['nomjob']),
        })
        # format of start time : [[MM]DD]HHmm (MM/DD compulsory ?)
        self.dict_info['depart'] = self.dict_info['depart'].replace(':', '')


    def change_script(self):
        """Modify submission 'script' file.
        """
        txt = ["#$ -N %(nomjob)s",
               "#$ -l s_cpu=%(tpmax)s,s_rss=%(memjob)sK",
               "#$ -e %(error)s",
               "#$ -o %(output)s"]
        #if self.dict_info.get('mpi_nbcpu'):
            #txt.append("""#$ -l num_cpu=%(mpi_nbcpu)s""")
        if self.dict_info.get('classe'):
            txt.append('''#$ -q "%(classe)s"''')
        if self.dict_info.get('depart'):
            txt.append("#$ -a %(depart)s")
        if self.dict_info.get('after_job'):
            txt.append("#$ -hold_jid %(after_job)s")
        if self.dict_info.get('custom'):
            txt.append("#$ %(custom)s")
        # core script
        core = super(SGE, self).change_script()
        txt.extend(core)
        return txt

    def parse_output(self, output):
        """Extract jobid and queue from output of submission.
        """
        # Ex.: Your job 789 ("my_job") has been submitted
        queue = 'unknown'
        jobid = output.split(' ')[2]
        return jobid, queue

    def parse_jobstate_output(self, output, jobinf):
        """Extract informations about the job state.
        """
        mat = re.search('(^ *%s.*)' % jobinf.jobid, output, re.MULTILINE)
        if mat == None:
            jobinf.state = "ENDED"
        else:
            lin = mat.group(1).split()
            if len(lin) >= 5:
                etat = lin[4]
                if re.search('[wh]+', etat) != None:
                    jobinf.state = "PEND"
                elif re.search('[sST]+', etat) != None:
                    jobinf.state = "SUSPENDED"
                else:
                    jobinf.state = "RUN"
                if len(lin) >= 8:
                    l_q = lin[7].split('@')
                    jobinf.queue = l_q[0]
                    if len(l_q) > 1:
                        jobinf.node  = l_q[1].split('.')[0]
        return jobinf

    def parse_jobcpu(self, output, jobinf):
        """Extract the cputime used by the job."""
        # because I don't known the running node on which to call 'ps'
        expr = re.compile('^usage *[0-9]* *: *cpu=([0-9:]+)', re.MULTILINE)
        l_field = expr.findall(output)
        jobinf.cputime = dhms2s(l_field)
        return jobinf


class SLURM(BatchSystem):
    """for Slurm batch system."""
    bsub = 'sbatch'
    bjid = 'SLURM_JOB_ID'
    bjob = 'squeue -o "%i %P %t %M %N"'
    cmdjob = '%(bjob)s -u %(username)s'
    bkil = 'scancel'
    bsig = bkil
    cmdsig = '%(bsig)s --signal=%(signal)s --batch %(jobid)s'
    _conv_state = {
        'CF' : 'PEND',
        'PD' : 'PEND',
        'R' : 'RUN',
        'S' : 'SUSPENDED',
    }

    def build_dict_info(self):
        """Add infos into dict_info.
        """
        super(SLURM, self).build_dict_info()
        # %J means jobid.stepid
        memNode = self.prof['memoryNode'][0]
        if not memNode:
            memNode = float(self.prof['memjob'][0]) / 1024.
        memNode = int(float(memNode))
        self.dict_info.update({
            'memoryNodeMB': memNode,
            'error'     : osp.join(self.run['flasheur'], '%s.e%%j' % self.dict_info['nomjob']),
            'output'    : osp.join(self.run['flasheur'], '%s.o%%j' % self.dict_info['nomjob']),
        })

    def change_script(self):
        """Modify submission 'script' file.
        """
        core = super(SLURM, self).change_script()
        txt = [core.pop(0),]
        txt.extend(["#SBATCH --job-name=%(nomjob)s",
                    "#SBATCH --time=%(tpsjob)s",
                    "#SBATCH --mem=%(memoryNodeMB)s",
                    "#SBATCH --output=%(output)s",
                    "#SBATCH --error=%(error)s",])
        # output/error will be named %(nomjob).o%(jobid) in the directory where qsub has been run
        if self.dict_info.get('mpi_nbcpu'):
            txt.append("#SBATCH --ntasks=%(mpi_nbcpu)s")
        if self.dict_info.get('mpi_nbnoeud'):
            txt.append("#SBATCH --nodes=%(mpi_nbnoeud)s")
        if self.dict_info.get('classe'):
            txt.append('''#SBATCH --partition="%(classe)s"''')
        if self.dict_info.get('depart'):
            txt.append("#SBATCH --begin=%(depart)s")
        if self.dict_info.get('after_job'):
            txt.append("#SBATCH --dependency=after:%(after_job)s")
        if self.dict_info.get('custom'):
            txt.append("#SBATCH %(custom)s")

        # core script
        txt.extend(core)
        return txt

    def parse_output(self, output):
        """Extract jobid and queue from output of submission.
        """
        # Ex.: "Submitted batch job 57574"
        #print output
        queue = 'unknown'
        jobid = output.split(' ')[3].strip()
        return jobid, queue

    def parse_jobstate_output(self, output, jobinf):
        """Extract informations about the job state.
        """
        reg = re.compile('^( *%s .*)$' % jobinf.jobid, re.M)
        line = reg.findall(output)
        #self.run.Mess(ufmt(_(u'output : %s\nfound : %s'), output, line))
        if line:
            spl = line.pop().split()
            if len(spl) >= 2:
                jobinf.queue = spl[1]
            if len(spl) >= 3:
                jobinf.state = self._conv_state.get(spl[2])
            if len(spl) >= 4:
                try:
                    jobinf.cputime = dhms2s(spl[3])
                except ValueError:
                    self.run.Mess(ufmt(_('unexpected value: %s'), output))
            if len(spl) >= 5:
                jobinf.node = spl[4]
        else:
            jobinf.state = 'ENDED'
        return jobinf


def BatchSystemFactory(run, prof=None, **kwargs):
    name = (prof and prof['batch_nom'][0]) or run.get('batch_nom', '')
    name = name.lower()
    if   name == 'lsf':
        return LSF(run, prof, **kwargs)
    elif name == 'pbs':
        return PBS(run, prof, **kwargs)
    elif name == 'pbs_nosplitjobid':
        return PBS_NoSplitJobId(run, prof, **kwargs)
    elif name == 'sunge':
        return SGE(run, prof, **kwargs)
    elif name == 'slurm':
        return SLURM(run, prof, **kwargs)
    else:
        raise BatchError("unknown batch scheduler : '%s'" % name)
