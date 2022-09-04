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
Definition of AsterCalcul class and its derivated.
"""

import os
import os.path as osp
import re
import time
from collections import namedtuple

from asrun.installation     import confdir
from asrun.common.i18n      import _
from asrun.core             import magic
from asrun.mystring         import convert, ufmt, to_unicode
from asrun.job              import Func_actu, Func_tail, Del
from asrun.build            import AsterBuild
from asrun.config           import build_config_from_export
from asrun.profil           import AsterProfil
from asrun.system           import shell_cmd
from asrun.execution        import build_test_export
from asrun.batch            import BatchSystemFactory
from asrun.profile_modifier import apply_special_service, setSlaveParameters
from asrun.common_func      import get_tmpname, flash_filename, is_localhost2, same_hosts2
from asrun.common.rcfile    import get_nodepara
from asrun.common.utils     import find_command, YES_VALUES, NO_VALUES, get_plugin

from asrun.backward_compatibility import bwc_deprecate_class


msg_info = """###############################################
           Client name : %(mcli)s
              Username : %(ucli)s
%(sep)s
           Server name : %(serv)s
              Username : %(user)s
                  Node : %(node)s
              Platform : %(plt)s
%(sep)s
    Code_Aster version : %(vers)s
%(sep)s
            Time (min) : %(tpsjob)s
           Memory (MB) : %(vmem).1f
  Number of processors : %(ncpus)s   (OpenMP)
       Number of nodes : %(mpi_nbnoeud)s   (MPI)
  Number of processors : %(mpi_nbcpu)s   (MPI)
                  Mode : %(mode)s
%(sep)s
            Debug mode : %(dbg)s"""

msg_classe  = " specified batch queue : %s"
msg_depart  = "            start time : %s"
msg_consbtc = "            BTC script : %s"
msg_vers  = """   Version ASTK Server : %s
        Version Client : %s
###############################################
"""


class BaseCalcul(object):
    """Common part between AsterCalcul and AsterCalcHandler objects."""

    def __init__(self):
        self.prof = None
        self.scheduler = None
        self.jobid = -1
        self.studyid = -1
        self.queue = "unknown"
        self.name = "unnamed"
        self.diag = '?'
        self.start_time = self.end_time = None

    def error(self, msg):
        """Print an error msg and exit."""
        magic.run.Mess(msg, '<F>_ERROR')

    def start(self, *args, **kwargs):
        self.is_starting()
        raise NotImplementedError('must be defined in a derivated class')

    def is_starting(self):
        """Mark as started."""
        self.start_time = time.time()

    def finish(self, state):
        """Mark as ended if state is ENDED."""
        if state == 'ENDED':
            self.end_time = time.time()

    def is_ended(self):
        """Tell if the calculation is ended."""
        return self.end_time is not None

    def get_state(self):
        """Return current state of the job."""
        # should call finish() to fill end_time
        raise NotImplementedError('must be defined in a derivated class')

    def tail(self, **kwargs):
        """Return tail of current output of the job."""
        raise NotImplementedError('must be defined in a derivated class')

    def wait(self, refresh_delay=1.):
        """Wait for job completion."""
        state = '_'
        while state != 'ENDED':
            time.sleep(refresh_delay)
            res = self.get_state()
            state, diag = res[0:2]
        self.diag = diag

    def get_diag(self):
        """Return diagnostic of the execution based on the output file."""
        raise NotImplementedError('must be defined in a derivated class')

    def kill(self):
        """Kill the job (if it is running) and delete of its files."""
        raise NotImplementedError('must be defined in a derivated class')

    def request(self, key):
        """Return the value to request."""
        if key == 'cpu':
            res = max(int(self.prof['ncpus'][0] or 1), int(self.prof['mpi_nbcpu'][0] or 1))
        elif key == 'mem':
            res = float(self.prof['memjob'][0] or 0.) / 1024.
        else:
            res = 0
        return res

    def on_host(self, serv, node):
        """Change submission serv/node.
        """
        if serv is not None:
            self.prof['serveur'] = serv
        if node is not None:
            self.prof['noeud'] = node


class AsterCalcul(BaseCalcul):
    """This class read user's profile and (if needed) call as_run through or not
    a terminal, or just write a btc file...
    """
    _supported_services     = ('study', 'parametric_study', 'testcase', 'meshtool',
                               'stanley', 'convbase', 'distribution', 'exectool',
                               'multiple',)

    def __init__(self, run, filename=None, prof=None, pid=None, differ_init=False):
        """Initializations
        """
        BaseCalcul.__init__(self)
        assert filename or prof, 'none of (filename, prof) provided!'
        self.run = run
        if pid is None:
            self.pid = self.run['num_job']
        else:
            self.pid = pid
        self.studyid = self.pid

        if prof is not None:
            self.prof = prof
        else:
            # ----- profile filename
            fprof = get_tmpname(self.run, self.run['tmp_user'], basename='profil_astk')
            self.run.ToDelete(fprof)
            kret = self.run.Copy(fprof, filename, niverr='<F>_PROFILE_COPY')
            self.prof = AsterProfil(fprof, self.run)
        if self.prof['nomjob'][0] == '':
            self.prof['nomjob'] = 'unnamed'

        # attributes
        self.dict_info   = None
        self.as_exec_ref = self.run.get('as_exec_ref')
        self.diag        = '?'
        self.__initialized = False

        if not differ_init:
            self.finalize_init()


    def finalize_init(self):
        """Finalize initialization.
        Allow to adapt prof object before customization."""
        # decode service called
        self.decode_special_service()
        # add memory
        self.add_memory()
        # allow customization of calcul object
        if self.run['schema_calcul']:
            schem = get_plugin(self.run['schema_calcul'])
            self.run.DBG("calling plugin : %s" % self.run['schema_calcul'])
            self.prof = schem(self)

        self.__initialized = True


    def decode_special_service(self):
        """Return the profile modified for the "special" service.
        """
        self.serv, self.prof = apply_special_service(self.prof, self.run)
        if self.serv == '':
            if self.prof['parent'][0] == 'parametric':
                self.serv = 'parametric_study'
            elif self.prof['parent'][0] == 'astout':
                self.serv = 'testcase'
            else:
                self.serv = 'study'

        self.prof['service'] = self.serv
        self.run.DBG("service name : %s" % self.serv)
        if self.serv not in self._supported_services:
            self.error(_('Unknown service : %s') % self.serv)

    def add_memory(self):
        """Add an amount of memory (MB) to the export parameters"""
        conf = build_config_from_export(self.run, self.prof)
        self.run.DBG("memory to add: %s" % conf['ADDMEM'][0])
        try:
            addmem = float(conf['ADDMEM'][0])
        except ValueError:
            addmem = 0.
        if not addmem:
            return
        memory = float(self.prof['memjob'][0] or 0.) / 1024. + addmem
        self.prof.set_param_memory(memory)
        self.run.DBG("new memory parameters: memjob=%s  memjeveux=%s" % \
                     (self.prof['memjob'][0], self.prof.args['memjeveux']))

    def build_dict_info(self, opts):
        """Build a dictionnary grouping all parameters.
        """
        sep = "-----------------------------------------------"
        self.mode = self.prof['mode'][0]
        if not self.mode or self.run.get(self.mode) not in YES_VALUES:
            self.mode = self.prof['mode'] = "interactif"
        if self.mode == 'batch':
            self.scheduler = BatchSystemFactory(self.run, self.prof)
        node = self.prof['noeud'][0] or self.prof['serveur'][0]
        self.dict_info = {
            'sep'                   : sep,
            'export'                : self.prof.get_filename(),
            'mcli'                  : self.prof['mclient'][0],
            'ucli'                  : self.prof['uclient'][0],
            'serv'                  : self.prof['serveur'][0],
            'user'                  : self.prof['username'][0],
            'mode'                  : self.mode,
            'node'                  : node,
            'plt'                   : self.run['plate-forme'],
            'vers'                  : self.prof.get_version_path(),
            'tpsjob'                : self.prof['tpsjob'][0],
            'vmem'                  : float(self.prof['memjob'][0] or 0.) / 1024.,
            'ncpus'                 : self.prof['ncpus'][0] or 'auto',
            'mpi_nbnoeud'           : self.prof['mpi_nbnoeud'][0],
            'mpi_nbcpu'             : self.prof['mpi_nbcpu'][0],
            'dbg'                   : self.prof['debug'][0],
            'prof_content'          : self.prof.get_content(),
            'nomjob'                : self.prof['nomjob'][0],
            'nomjob_'               : self.flash('', ''),
            'nomjob_p'              : self.flash('export', '$num_job'),
            'as_run_cmd'            : " ".join(self.run.get_as_run_cmd(with_args=False)),
            'who'                   : self.run.system.getuser_host()[0],
            'opts'                  : opts,
            'remote_args'           : " ".join(self.run.get_as_run_args()),
            'opt_num_job'           : "--num_job=$num_job",
        }

        if self.prof['srv_dbg'][0] in YES_VALUES:
            self.dict_info['opts'] += ' --debug'
        if self.prof['srv_verb'][0] in YES_VALUES:
            self.dict_info['opts'] += ' --verbose'

        # rep_trav from profile or config(_nodename) / keep consistancy with job.py
        rep_trav = self.prof['rep_trav'][0]
        if rep_trav == '':
            rep_trav = get_nodepara(node, 'rep_trav', self.run['rep_trav'])
        self.dict_info['rep_trav'] = rep_trav
        # set message using previous content
        self.dict_info['message'] = self.message()

        # switch to run_aster
        runaster = osp.join(osp.dirname(osp.dirname(self.dict_info["vers"])),
                            "bin", "run_aster")
        if osp.isfile(runaster):
            self.dict_info["as_run_cmd"] = runaster
            self.dict_info["opt_num_job"] = ""
            self.dict_info["remote_args"] = ""

    def message(self):
        """Format information message.
        """
        # No "' in ASTK_MESSAGE !
        ASTK_MESSAGE = []

        # check client and server versions
        serv_vers = self.run.__version__
        try:
            client_vers = self.prof['origine'][0]
        except Exception as msg:
            self.run.DBG('Error : unexpected "origine" value :', self.prof['origine'][0])
            client_vers = ''

        ASTK_MESSAGE.append(msg_info % self.dict_info)

        if self.prof['classe'][0]:
            ASTK_MESSAGE.append(msg_classe % self.prof['classe'][0])
        if self.prof['depart'][0]:
            ASTK_MESSAGE.append(msg_depart % self.prof['depart'][0])
        ASTK_MESSAGE.append(self.dict_info['sep'])

        if self.prof['consbtc'][0] not in NO_VALUES:
            msg = "generated"
        else:
            msg = "provided by user"
        ASTK_MESSAGE.append(msg_consbtc % msg)
        ASTK_MESSAGE.append(self.dict_info['sep'])

        ASTK_MESSAGE.append(msg_vers % (serv_vers, client_vers))

        return convert(os.linesep.join(ASTK_MESSAGE))


    def consbtc(self, fbtc):
        """Write btc file.
        """
        assert type(self.dict_info) is dict

        aster_profile = osp.join(confdir, 'profile.sh')
        if osp.exists(aster_profile):
            str_aster_profile = '. %s' % aster_profile
        else:
            str_aster_profile = ''
        if self.mode == 'interactif':
            m = 'i'
            str_pid = 'num_job=%s' % self.pid
        else:
            m = 'b'
            # ne conserver que le numero (par ex: 12345@node12 => 12345)
            str_pid = """num_job=`echo $%s | awk '{inv=$0; sub("^[0-9]+","",inv); """ \
                      """sub(inv,"",$0); print $0;}'`""" % self.scheduler.bjid

        btc = r"""#!/bin/bash

%(str_aster_profile)s
# Do not change the following line (used and changed if consbtc=no)
%(str_pid)s

# copie du .export dans le flasheur et rep_trav
cat << EOFEXPORT > %(nomjob_p)s
%(prof_content)s
EOFEXPORT

# on redéfinit car déjà arrivé en dhcp ou quand on change de noeud...
LOGNAME=%(who)s
export LOGNAME

# message d'info
printf %(message)r

# protection du fort.6
touch %(rep_trav)s/%(nomjob)s.$num_job.fort.6.%(m)s
chmod 600 %(rep_trav)s/%(nomjob)s.$num_job.fort.6.%(m)s

# lance l'exec
%(as_run_cmd)s %(opts)s %(nomjob_p)s \
        %(opt_num_job)s \
        %(remote_args)s \
        | tee %(rep_trav)s/%(nomjob)s.$num_job.fort.6.%(m)s

# diagnostic
egrep -- '^ *--- DIAGNOSTIC JOB :' %(rep_trav)s/%(nomjob)s.$num_job.fort.6.%(m)s | awk '{print $5}' | tail -1 > %(nomjob_)s%(m)s$num_job
\rm -f %(rep_trav)s/%(nomjob)s.$num_job.fort.6.%(m)s

\rm -rf %(fbtc)s

"""
        dict_btc = self.dict_info.copy()
        dict_btc.update({
            'str_aster_profile'  : str_aster_profile,
            'str_pid'            : str_pid,
            'm'                  : m,
            'fbtc'               : fbtc,
        })

        with open(fbtc, 'w') as f:
            f.write(btc % dict_btc)
        os.chmod(fbtc, 0o755)
        time.sleep(0.5)

    def change_btc(self, fbtc):
        """Change a provided btc script file"""
        # use the current jobid
        with open(fbtc, 'r') as f:
            content = f.read()
        exp = re.compile('^(num_job=.*)$', re.MULTILINE)
        if self.mode == 'interactif':
            pid = self.pid
        else:
            pid = self.scheduler.bjid
        content = exp.sub('num_job=%s' % pid, content)
        # update the file
        with open(fbtc, 'w') as f:
            f.write(content)


    def soumbtc_batch(self, fbtc):
        """Run btc script in batch mode.
        """
        self.scheduler.set_subpara(fbtc, change_input_script=True)
        iret, jobid, queue = self.scheduler.start()
        if iret != 0:
            print(_("Error during submitting job !"))
            iret = 5
        if jobid == '':
            print(_("Empty jobid"))
            iret = 5
        return iret, jobid, queue


    def soumbtc_interactif(self, fbtc):
        """Run btc in interactive mode.
        """
        self.jobid = self.pid
        # commandes
        cmd_batch      = '%(fbtc)s 1> %(output)s 2> %(error)s'
        cmd_interactif = '%(fbtc)s 2> %(error)s | tee %(output)s'

        node = self.dict_info['node']
        dico = {
            'fbtc'   : fbtc,
            'output' : self.flash('output'),
            'error'  : self.flash('error'),
        }
        # follow output or not
        xterm = ''
        if self.prof['follow_output'][0] in YES_VALUES:
            xterm   = self.run['terminal']

        if self.prof['depart'][0] != '' or xterm == '':
            cmd = cmd_batch % dico
        else:
            cmd = cmd_interactif % dico

        # delayed start
        if self.prof['depart'][0] != '':
            cmd = "echo '%s' | at %s" % (cmd, self.prof['depart'][0])
        elif xterm != '':
            if re.search('@E', xterm) == None:
                xterm = xterm + ' -e @E'
            cmd = xterm.replace('@E', '%s "%s"' % (shell_cmd, cmd))

        # run on another node
        distant = not is_localhost2(node)

        if not distant:
            # check xterm command
            if xterm != '':
                term = xterm.split()[0]
                if not os.access(term, os.X_OK):
                    print(_("Not an executable : %s") % term)
                    return 7, '', 'unknown'
        else:
            # check node connection
            iret, output = self.run.Shell('echo hello', mach=node)
            if output.find('hello') < 0:
                print(output)
                print(_("Connection failure to %s (from %s)") % (node, self.prof['serveur'][0]))
                return 6, '', 'unknown'

        # background is not possible if display forwarding is required
        # (the connection must stay alive)
        need_display = xterm != ''
        background = (not need_display) \
            or same_hosts2(self.prof['mclient'][0], node,
                           self.prof['uclient'][0], self.prof['username'][0])
        kret, output = self.run.Shell(cmd, mach=node, bg=background,
                                    display_forwarding=need_display)

        return 0, self.jobid, 'interactif'

    def start(self, options=''):
        """Go !
        """
        self.is_starting()
        self.run.DBG('Profile to run', self.prof.get_content(), all=True)
        # ----- copy and read .export, build dict for formatting
        self.build_dict_info(options)

        if self.run.get('log_usage_version') and self.serv != 'testcase':
            from asrun.contrib.log_usage import log_usage_version_unfail
            log_usage_version_unfail(self.run['log_usage_version'], self.prof)

        jn = self.pid
        self.name = self.prof['nomjob'][0]

        if self.run.get(self.mode) not in YES_VALUES:
            print(ufmt(_("the configuration file (%s) does not allow mode='%s'"),
                        osp.join(confdir, "asrun"), self.mode))
            return 4, ""

        # export file is not necessary in interactive mode
        if self.mode == 'batch':
            self.prof.WriteExportTo(self.prof.get_filename())
            self.run.DBG('profile written into :', self.prof.get_filename())

        # ----- consbtc ?
        fbtc = osp.join(self.run['flasheur'], 'btc.%s' % jn)
        if self.prof['consbtc'][0] in NO_VALUES and not 'make_env' in self.prof['actions']:
            fbtc0 = self.prof.Get('D', 'btc')[0]['path']
            iret = self.run.Copy(fbtc, fbtc0)
            self.change_btc(fbtc)
        else:
            self.consbtc(fbtc)

        # ----- soumbtc ?
        iret = 0
        if self.prof['soumbtc'][0] not in NO_VALUES:
            if self.mode == 'interactif':
                iret, jobid, self.queue = self.soumbtc_interactif(fbtc)
            else:
                iret, jobid, self.queue = self.soumbtc_batch(fbtc)
            if iret == 0:
                self.jobid = jobid

            # copy fbtc into flasheur/ (already removed if run in foreground)
            if osp.exists(fbtc):
                jret = self.run.Copy(self.flash('script'), fbtc, niverr='<A>_ALARM')

        # faut-il recopier le btc vers le client
        res_fbtc = self.prof.Get('R', 'btc')
        if len(res_fbtc) > 0:
            res_fbtc = res_fbtc[0]['path']
            self.run.Copy(res_fbtc, fbtc)
            print("BTCFILE=%s" % res_fbtc)

        return iret, ''


    def flash(self, typ, num_job=None):
        """If typ='o', return something like .../flasheur/nomjob.o1234"""
        assert self.prof is not None
        if num_job is None:
            num_job = self.jobid
        return flash_filename(magic.run['flasheur'], self.prof['nomjob'][0], num_job, typ)


    def get_state(self):
        """Return current state of the job."""
        res = Func_actu(self.run, self.jobid, self.name, self.mode)
        self.finish(res[0])
        return res


    def get_diag(self):
        """Return diagnostic of the execution based on the output file."""
        res = self.get_state()
        state, diag = res[0:2]
        res = [diag, 0., 0., 0., 0.]
        self.diag = diag
        if state == 'ENDED' and osp.exists(self.flash('output')):
            with open(self.flash('output'), 'rb') as f:
                txt = to_unicode(f.read())
            mat = re.search('%s +([0-9\.]+) +([0-9\.]+) +([0-9\.]+) +([0-9\.]+)' % 'Total', txt)
            if mat is not None:
                res = res[:1] + [float(v) for v in mat.groups()]
        return res


    def tail(self, nbline=50, expression=None):
        """Return tail of current output of the job."""
        return Func_tail(self.run, self.jobid, self.name, self.mode, nbline, expression)


    def kill(self):
        """Kill the job (if it is running) and delete of its files."""
        Del(self.run, self.jobid, self.name, self.mode, signal='KILL')



class AsterCalcTestcase(AsterCalcul):
    """Derivation for a testcase.
    """
    def __init__(self, run, test, filename=None, prof=None, pid=None, **kwargs):
        """Initializations """
        if prof is not None:
            prof['parent'] = 'astout'
        AsterCalcul.__init__(self, run, filename, prof, pid, differ_init=True)
        self.testcase = test
        self.param = kwargs.copy()
        self.prof = self.change_profile()
        self.finalize_init()


    def change_profile(self):
        """Prepare profile object.
        """
        # initialize the profile
        ptest = init_profil_from(self.run, self.prof.copy())
        fname = get_tmpname(self.run, self.run['tmp_user'],
                            basename=self.testcase + '.export', pid=self.pid)
        ptest.set_filename(fname)
        self.run.DBG('profile filename set to : ', fname)
        del ptest['follow_output']
        del ptest['rep_trav']
        del ptest['detr_rep_trav']
        del ptest['depart']
        del ptest['mem_aster']

        # update with the export to run the test
        lunig = ptest.get_type('unig')
        d_unig = None
        if lunig:
            unigest = lunig[0].path
            conf = build_config_from_export(self.run, ptest)
            build = AsterBuild(self.run, conf)
            d_unig = build.GetUnigest(unigest)
        prt = build_test_export(self.run, self.param['conf'], self.param['REPREF'],
                                self.param['reptest'], self.testcase, self.param['resutest'],
                                with_default=False, d_unig=d_unig)
        prt['nomjob'] = self.testcase
        ptest.update(prt)

        # apply facmtps
        try:
            ptest['time_limit'] = int(float(ptest['time_limit'][0]))  * self.param['facmtps']
        except Exception:
            pass
        try:
            ptest['tpsjob'] = int(float(ptest['tpsjob'][0]))  * self.param['facmtps']
        except Exception:
            pass
        try:
            ptest.args['tpmax'] = int(float(ptest.args['tpmax']))  * self.param['facmtps']
        except Exception:
            pass

        ptest.update_content()
        return ptest

    def clean_results(self):
        """Remove all result files"""
        resu = self.prof.Get('R', 'resu')[0]['path']
        mess = self.prof.Get('R', 'mess')[0]['path']
        code = self.prof.Get('R', 'code')[0]['path']
        for f in (resu, mess, code):
            self.run.Delete(f)


class AsterCalcParametric(AsterCalcul):
    """Derivation for a parametric study :
        - change all "comm" files
        - change repe_out into resudir/calc_000i
    """
    def __init__(self, run, label, filename=None, prof=None, pid=None, **kwargs):
        """Initializations. Required arguments : resudir, keywords, values + prof['repe']
        """
        if prof is not None:
            prof['parent'] = 'parametric'
        AsterCalcul.__init__(self, run, filename, prof, pid, differ_init=True)
        self.label = label
        self.resudir = kwargs['resudir']
        try:
            os.makedirs(osp.join(self.resudir, label))
        except OSError:
            pass
        self.values   = kwargs['values'].copy()
        self.keywords = kwargs['keywords'].copy()
        self.prof = self.change_profile()
        self.finalize_init()


    def change_profile(self):
        """Prepare profile object.
        """
        prof = self.prof.copy()
        fname = get_tmpname(self.run, self.run['tmp_user'],
                            basename=self.label + '.export', pid=self.pid)
        prof.set_filename(fname)
        self.run.DBG('profile filename set to : ', fname)
        prof['actions'] = 'make_etude'
        prof['nomjob']  = '%s-%s' % (self.prof['nomjob'][0], self.label)
        # restore master parameters
        setSlaveParameters(prof)
        # delete unused entries
        assert prof.Get('R', typ='repe')
        del prof['follow_output']
        del prof['rep_trav']
        del prof['detr_rep_trav']
        del prof['depart']
        prof.Del('D', typ='distr')
        compress = prof.Get('R', typ='repe')[0]['compr']
        prof.Del('R', typ='repe')
        # add repe_out
        prof.Set('R', {
            'type'  : 'repe', 'isrep' : True, 'ul' : 0,
            'path'  : osp.join(self.resudir, self.label, 'REPE_OUT'),
            'compr' : compress,
        })
        # add base or bhdf as data
        type_base, compress = prof.get_base('D')
        if type_base:
            path = prof.Get('D', typ=type_base)[0]['path']
            prof.Del('D', typ=type_base)
            prof.Set('D', {
            'type'  : type_base, 'isrep' : True, 'ul' : 0,
            'path'  : osp.join(path, self.label, type_base),
            'compr' : compress,
            })
        # add base or bhdf as result
        type_base, compress = prof.get_base('R')
        if type_base:
            prof.Del('R', typ=type_base)
            prof.Set('R', {
            'type'  : type_base, 'isrep' : True, 'ul' : 0,
            'path'  : osp.join(self.resudir, self.label, type_base),
            'compr' : compress,
            })
        # change comm files
        lcomm = prof.Get('D', typ='comm')
        prof.Del('D', typ='comm')
        for i, df in enumerate(lcomm):
            fcom = osp.join(self.resudir, self.label, 'command_%d.comm' % i)
            dest = fcom
            if df['compr']:
                dest = dest + '.gz'
            kret = self.run.Copy(dest, df['path'], niverr='<E>_COPY_ERROR')
            if kret == 0 and df['compr']:
                kret, bid = self.run.Gunzip(dest, niverr='<E>_UNCOMPRESS')
            df.update({ 'compr' : False, 'path' : fcom })
            prof.Set('D', df)
            self.change_comm_files(dest)
        # move all results (as files) in resudir/label
        for dicf in prof.resu:
            if dicf['isrep']:
                continue
            dicf['path'] = osp.join(self.resudir, self.label, osp.basename(dicf['path']))
        return prof

    def change_comm_files(self, filename):
        """Change parameter definition in comm file.
        """
        assert osp.exists(filename), filename
        with open(filename, 'r') as f:
            content = f.read()
        for para, pval in list(self.values.items()):
            exp = re.compile('^( *)(%s *=.*)$' % para, re.MULTILINE)
            content = exp.sub('\g<1>%s = %s' % (para, pval), content)
        # insert commands at the beginning of each calculation
        if self.keywords.get('UNITE_PRE_CALCUL') or self.keywords.get('PRE_CALCUL'):
            ideb, jdeb = find_command(content, 'DEBUT')
            if self.keywords.get('PRE_CALCUL'):
                insert = self.keywords['PRE_CALCUL']
            if self.keywords.get('UNITE_PRE_CALCUL'):
                insert = """INCLUDE(UNITE=%s)""" % self.keywords['UNITE_PRE_CALCUL']
            content = os.linesep.join([content[:jdeb+1], insert, content[jdeb+1:]])
        # insert commands at the end of each calculation
        if self.keywords.get('UNITE_POST_CALCUL') or self.keywords.get('POST_CALCUL'):
            ifin, jfin = find_command(content, 'FIN')
            if self.keywords.get('POST_CALCUL'):
                insert = self.keywords['POST_CALCUL']
            if self.keywords.get('UNITE_POST_CALCUL'):
                insert = """INCLUDE(UNITE=%s)""" % self.keywords['UNITE_POST_CALCUL']
            content = os.linesep.join([content[:ifin], insert, content[ifin:]])

        with open(filename, 'w') as f:
            f.write(content)


def init_profil_from(run, prof, keep_surch=True):
    """Initialize an empty profile from another one.
    """
    # prepare the profile
    ptest = prof.copy()
    ptest.data = []
    if keep_surch:
        for data in prof.data:
            if data['type'] in ('exec', 'ele', 'cmde', 'conf', 'py'):
                ptest.data.append(data.copy())
    ptest.resu = []
    ptest['actions'] = 'make_etude'
    # machine
    if ptest['origine'][0] == '':
        ptest['origine'] = 'ASTK %s' % run.__version__
    ptest['uclient'], ptest['mclient'] = run.system.getuser_host()
    if ptest['serveur'][0] == '':
        ptest['serveur'] = ptest['mclient']
    if ptest['noeud'][0] == '':
        ptest['noeud'] = ptest['mclient']
    if ptest['username'][0] == '':
        ptest['username'] = ptest['uclient']
    for k in ('ncpus', 'mpi_nbnoeud', 'mpi_nbcpu'):
        if ptest[k][0] == '':
            ptest[k] = 1
    return ptest


def parse_submission_result(txt):
    """Decode a such string 'JOBID=  232564  QUEUE=  q4G_1h'.
    """
    # must be consistent with i_serv.tcl
    jobid, queue = '?', 'unknown'
    mat = re.search('JOBID *= *([0-9a-zA-Z\._\-]+)', txt)
    if mat is not None:
        jobid = mat.group(1)
    mat = re.search('QUEUE *= *([0-9a-zA-Z\._\-]+)', txt)
    if mat is not None:
        queue = mat.group(1)
    studyid = jobid
    mat = re.search('STUDYID *= *([0-9a-zA-Z\._\-]+)', txt)
    if mat is not None:
        studyid = mat.group(1)
    return namedtuple('jobsubmit',
        ['jobid', 'queue', 'studyid'])(jobid, queue, studyid)


def parse_consbtc(txt):
    """Decode the string to find the btc script filename."""
    btc = None
    mat = re.search('BTCFILE *= *(.*)$', txt, re.MULTILINE)
    if mat is not None:
        btc = mat.group(1)
    return btc

ASTER_CALCUL = bwc_deprecate_class('ASTER_CALCUL', AsterCalcul)
ASTER_TESTCASE = bwc_deprecate_class('ASTER_TESTCASE', AsterCalcTestcase)
ASTER_PARAMETRIC = bwc_deprecate_class('ASTER_PARAMETRIC', AsterCalcParametric)
