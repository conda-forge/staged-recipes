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
Definition of Runner class.

Synopsis:
    as_run --serv fich.export
                V     directement (interactif)
                    ou via sub_script (batch)
    as_run fich.export
                V
    execute.py
                V
    PrepEnv dans /shared_tmp/interactif.xxx
                V
    mpirun script.sh -wd /shared_tmp/interactif.xxx
                >  parallel_cp tracker /shared_tmp/interactif.xxx /local_tmp/interactif.xxx.proc.#i
                >  cd /local_tmp/interactif.xxx.proc.#i
                >  ./asteru_mpi args
                >  if #i == 0:
                        cp /local_tmp/interactif.xxx.proc.#i/results /shared_tmp/interactif.xxx
"""


import os
import os.path as osp
import re
from asrun.installation import aster_root, datadir
from asrun.common.i18n import _
from asrun.core import magic
from asrun.mystring import ufmt, convert
from asrun.common_func  import get_tmpname
from asrun.common.utils import YES_VALUES

from asrun.backward_compatibility import bwc_deprecate_class


class Runner(object):

    """Store informations for MPI executions."""

    def __init__(self, defines=None):
        """Initialization needs "DEFS" field of AsterConfig object.
        """
        if defines is not None:
            self._use_mpi = '_USE_MPI' in defines
        else:
            self._use_mpi = False
        self._nbnode = 1
        self._nbcpu  = 1
        # directory used to prepare the environment (which will be copied for
        # each processor)
        self.global_reptrav = ''
        # directory used for each execution (local to each processor)
        self.local_reptrav  = ''

        self.timer_comment = _("""(*) cpu and system times may be not correctly""" \
                                """ counted using mpirun.""")


    def set_cpuinfo(self, nbnode, nbcpu):
        """Set values of number of processors, of nodes.
        """
        iret = 0
        try:
            self._nbcpu = int(nbcpu or 1)
        except ValueError:
            iret = 4
            self._nbcpu = 1
        self._nbcpu = max(self._nbcpu, 1)
        try:
            self._nbnode = int(nbnode or 1)
        except ValueError:
            iret = 4
            self._nbnode = 1
        self._nbnode = max(self._nbnode, 1)
        self._nbnode = min(self._nbnode, self._nbcpu)
        if not self._use_mpi:
            if self._nbnode > 1 or self._nbcpu > 1:
                iret = 1
            self._nbnode = 1
            self._nbcpu  = 1
        return iret


    def really(self):
        """Return True if Code_Aster executions need mpirun."""
        return self._use_mpi


    def set_rep_trav(self, reptrav, basename=''):
        """Set temporary directory for Code_Aster executions."""
        run = magic.run
        if reptrav:
            self.local_reptrav = self.global_reptrav = reptrav
            if self.really():
                self.global_reptrav = osp.join(reptrav, 'global')
                if not osp.exists(self.global_reptrav):
                    os.makedirs(self.global_reptrav)
        else:
            self.local_reptrav = self.global_reptrav = get_tmpname(run, basename=basename)
            # used shared directory only if more than one node
            if self.really():
                # and self.nbnode() > 1: shared_tmp is necessary if submission
                # node is not in mpihosts list
                # MUST not contain local_reptrav
                dirn = get_tmpname(run, run['shared_tmp'], basename)
                self.global_reptrav = osp.join(dirn, 'global')
        run.DBG("set_rep_trav(%s) > local=%s, global=%s" \
                % (reptrav, self.local_reptrav, self.global_reptrav),
                stack_id=1)
        return self.global_reptrav

    def build_dict_mpi_args(self):
        """Return dict arguments to build the script."""
        run = magic.run
        dict_mpi_args = {
            'mpirun_cmd'         : run['mpirun_cmd'],
            'mpi_ini'            : run.get('mpi_ini'),
            'mpi_end'            : run.get('mpi_end'),
            'mpi_get_procid_cmd' : run['mpi_get_procid_cmd'],
            'mpi_hostfile'       : run.get('mpi_hostfile'),
            'mpi_nbnoeud'        : self.nbnode(),
            'mpi_nbcpu'          : self.nbcpu(),
            'wrkdir'             : self.global_reptrav,
            'local_wrkdir'       : self.local_reptrav,
            'num_job'            : run['num_job'],
            'content_after_msg'  : _('Content after execution of'),
        }
        return dict_mpi_args


    def get_exec_command(self, cmd_in, add_tee=False, env=None):
        """Return command to run Code_Aster.
        """
        run = magic.run
        # add source of environments files
        if env is not None and self.really():
            envstr = [". %s" % f for f in env]
            envstr.append(cmd_in)
            cmd_in = " ; ".join(envstr)
        dict_val = {
            'cmd_in' : cmd_in,
            'var'    : 'EXECUTION_CODE_ASTER_EXIT_%s' % run['num_job'],
        }
        if add_tee:
            cmd_in = """( %(cmd_in)s ; echo %(var)s=$? ) | tee fort.6""" % dict_val

        if not self.really():
            if add_tee:
                cmd_in += """ ; exit `grep -a %(var)s fort.6 | head -1 """ \
                          """| sed -e 's/%(var)s=//'`""" % dict_val
            return cmd_in

        mpi_script = osp.join(self.global_reptrav, 'mpi_script.sh')

        if run.get('use_parallel_cp') in YES_VALUES:
            cp_cmd = '%s --with-as_run %s %s' \
                % (osp.join(aster_root, 'bin', 'parallel_cp'),
                   " ".join(run.get_remote_args()),
                   self.global_reptrav)
        elif self.nbnode() > 1:
            cp_cmd = 'scp -r'
        else:
            cp_cmd = 'cp -r'

        dict_mpi_args = {
            'cmd_to_run' : cmd_in,
            'program'    : mpi_script,
            'cp_cmd'     : cp_cmd,
        }
        dict_mpi_args.update(self.build_dict_mpi_args())
        template = osp.join(datadir, 'mpirun_template')
        if not run.Exists(template):
            run.Mess(ufmt(_('file not found : %s'), template), '<F>_FILE_NOT_FOUND')
        with open(template, 'r') as f:
            content = f.read() % dict_mpi_args
        run.DBG(content, all=True)
        with open(mpi_script, 'w') as f:
            f.write(convert(content))
        os.chmod(mpi_script, 0o755)
        # add comment because cpu/system times are not counted by the timer
        self._add_timer_comment()
        # mpirun/mpiexec
        command = dict_mpi_args['mpirun_cmd'] % dict_mpi_args
        # need to initialize MPI session ?
        if dict_mpi_args['mpi_ini']:
            command = dict_mpi_args['mpi_ini'] % dict_mpi_args + " ; " + command
        # need to close MPI session ?
        if dict_mpi_args['mpi_end']:
            command = command + " ; " + dict_mpi_args['mpi_end'] % dict_mpi_args
        return command


    def nbcpu(self):
        """Return the number of cpu."""
        return self._nbcpu


    def nbnode(self):
        """Return the number of nodes"""
        return self._nbnode


    def reptrav(self, procid=None):
        """Return global workdir or local workdir on proc #i.
        """
        if procid is None or not self.really():
            res = self.global_reptrav
        else:
            # MUST BE consistant with mpirun_template (even if it's never used !)
            res = osp.join(self.local_reptrav, 'proc.%d' % procid)
        return res


    def add_to_timer(self, text, title):
        """Add info cpus to the timer reading 'text'.
        """
        run = magic.run
        if not hasattr(run, 'timer') or not self.really():
            return
        l_info_cpu = re.findall('PROC=([0-9]+) INFO_CPU=(.*)', text)
        l_info_cpu.sort()
        for procid, infos in l_info_cpu:
            cpu_mpi, sys_mpi = 0., 0.
            id_timer = _('  %s - rank #%s') % (title, procid)
            run.timer.Stop(id_timer)
            try:
                l_ch = re.sub(' +', ' ', infos.strip()).split(' ')
                assert len(l_ch) == 4, 'cpu+sys, cpu, sys, elapsed'
                cpu_mpi = float(l_ch[1])
                sys_mpi = float(l_ch[2])
            except (AssertionError, TypeError):
                run.Mess(_('Unable to retreive CPU info for proc #%s') % procid)
                run.DBG('Info CPU proc #%s' % procid, infos, l_ch)
            run.timer.Add(id_timer, cpu_mpi, sys_mpi)
            # add time spend in 'Code_Aster run' and to total
            run.timer.Add(title, cpu_mpi, sys_mpi, to_total=True)


    def _add_timer_comment(self):
        """Add a warning when mpirun is called without Aster.
        """
        run = magic.run
        if hasattr(run, 'timer') and self.really():
            run.timer.AddComment(self.timer_comment, init=True)
