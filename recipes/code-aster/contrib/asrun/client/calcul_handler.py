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
Manipulate a AsterCalcul-like object from the client side.
"""

import os.path as osp
from collections import namedtuple

from asrun.core import magic
from asrun.calcul import BaseCalcul, parse_submission_result
from asrun.profil import ExportEntry
from asrun.job import parse_actu_result, parse_tail_result
from asrun.plugins.actions import ACTIONS
from asrun.common.utils import get_plugin, YES_VALUES
from asrun.common_func  import flash_filename, is_localhost2
from asrun.common.sysutils  import local_host, short_hostname, FileName, get_home_directory

MULTIDIR = osp.join('$HOME', 'MULTI')


class AsterCalcHandler(BaseCalcul):
    """Similar to an AsterCalcul from the client point of view.
    Does not directly start a calculation or refresh its state but
    calls the corresponding service through its proxy function.
    """
    _act_serv = _act_actu = _act_del = _act_tail = _act_get_results = None

    def __init__(self, prof):
        """Initialization."""
        BaseCalcul.__init__(self)
        run = magic.run
        self.prof = prof
        self.name = prof['nomjob'][0]
        # store schemes : self._act_serv, self._act_actu...
        for act in ('serv', 'actu', 'del', 'tail', 'get_results'):
            funcname = "_act_%s" % act
            schema_name = magic.run.get('schema_%s' % act) \
                or ACTIONS[act]['default_schema']
            setattr(self, funcname, get_plugin(schema_name))

    def start(self, *args):
        """Go"""
        self.is_starting()
        # here should check required fields in self.prof
        if self.prof['mode'][0] != 'batch':
            self.prof['mode'] = 'interactif'
        iret, output = self._act_serv(self.prof, None, print_output=False)
        self.jobid, self.queue, self.studyid = parse_submission_result(output)
        self.prof['jobid'] = self.jobid
        return iret, output

    def get_state(self):
        """Return current state of the job."""
        iret, output = self._act_actu(self.prof, None, print_output=False)
        res = parse_actu_result(output)
        self.finish(res[0])
        return res      # etat, diag, node, tcpu, wrk, queue

    def get_diag(self):
        """Return diagnostic of the execution based on the output file."""
        res = self.get_state()
        state, diag = res[0:2]
        elaps = 0.
        if self.is_ended():
            elaps = self.end_time - self.start_time
        res = [diag, 0., 0., 0., elaps]
        self.diag = diag
        return res      # diag, cpu, sys, cpu+sys, elaps

    def get_results(self):
        """Copy the result files."""
        return self._act_get_results(self.prof, None)

    def tail(self, nbline=50, expression=''):
        """Return tail of current output of the job."""
        self.prof['tail_nbline'] = str(nbline)
        self.prof['tail_regexp'] = expression
        iret, output = self._act_tail(self.prof, None, print_output=False)
        restail = parse_tail_result(output)
        res = namedtuple('tail', ['state', 'diag', 'output'])(
            restail.state, restail.diag, output)
        return res      # etat, diag, output

    def kill(self):
        """Kill the job (if it is running) and delete of its files."""
        iret = self._act_del(self.prof, None, print_output=False, signal='KILL')

    def flash(self, typ, num_job=None):
        """If typ='o', return something like flasheur/nomjob.o1234"""
        # contrary to AsterCalcul.flash, the filename is relative to $HOME.
        assert self.prof is not None
        if num_job is None:
            num_job = self.jobid
        return flash_filename('flasheur', self.prof['nomjob'][0], num_job, typ)


class AsterCalcHdlrMulti(AsterCalcHandler):
    """Encapsulation of AsterCalcHandler for a multiple execution :
        - change serveur/username
        - put all results in the same directory.
    """
    def __init__(self, run, host, filename=None, prof=None, pid=None, **kwargs):
        """Initializations. Required arguments : config
        """
        self.run = run
        prof = prof.copy()
        if prof is not None:
            prof['parent'] = 'multiple'
        AsterCalcHandler.__init__(self, prof)
        self.studyid = pid
        self.host = short_hostname(host)
        self.name = prof['nomjob'][0] + '_' + self.host
        run.DBG('AsterCalculMutiple.init jobname : %s' % self.name)
        self._host_config = kwargs['config'].copy()
        self.prof = self.change_profile()
        run.DBG(repr(self.prof), all=True)

    def on_host(self, serv, host):
        """Change submission serv/host."""
        # does nothing. server is choosen at initialization.

    def change_profile(self):
        """Prepare profile object."""
        prof = self.prof.copy()
        cfg = self._host_config
        prof['service'] = 'study'
        prof['actions'] = prof['multiple_actions']
        prof['studyid'] = self.studyid
        del prof['multiple_actions']
        del prof['multiple']
        del prof['rep_trav']
        del prof['detr_rep_trav']
        del prof['follow_output']
        prof['serveur'] = cfg['nom_complet']
        prof['noeud'] = ''
        prof['username'] = cfg['login']
        prof['mclient'] = local_host
        prof['nomjob'] = self.name
        prof['protocol_exec'] = cfg['protocol_exec']
        prof['protocol_copyto'] = cfg['protocol_copyto']
        prof['protocol_copyfrom'] = cfg['protocol_copyfrom']
        prof['aster_root'] = cfg['rep_serv']
        prof['proxy_dir'] = cfg['proxy_dir']
        prof['mode'] = 'batch'
        if self._host_config.get('batch') not in YES_VALUES:
            prof['mode'] = 'interactif'
        # add a flash entry
        prof.add(ExportEntry('flash', type='flash', result=True, isrep=True))
        # results_dir
        # transfer results on the local client...
        new = osp.join(MULTIDIR, self.name)
        if not cfg['result_on_client']:
            # or relocate into the 'MULTIDIR' directory on each server
            new = "%s@%s:%s" % (cfg['login'], cfg['nom_complet'], new)
        self.results_dir = new
        self.change_datas(prof)
        self.change_results(prof)
        return prof

    def change_datas(self, prof):
        """Relocate the datas of types 'exec/cmde/ele' supposed to be built
        in a previous multiple execution."""
        surch = prof.get_type('exec')
        surch.update(prof.get_type('cmde'))
        surch.update(prof.get_type('ele'))
        surch = surch.get_data()
        # suppose to be on localhost, then relocate it to results_dir
        prof.relocate(serv=None, newdir=None, user='', fromlist=surch)
        prof.relocate(serv=None, newdir=self.results_dir, user='', fromlist=surch)

    def change_results(self, prof):
        """Relocate results"""
        cfg = self._host_config
        results = prof.get_result()
        # first suppose that all results are on localhost
        prof.relocate(serv=None, newdir=None, fromlist=results)
        # then relocate them in results_dir
        prof.relocate(serv=None, newdir=self.results_dir, fromlist=results)

    def request(self, key):
        """Return the value to request."""
        return 1

    def copy_flash(self):
        """Copy output/error to the flash directory. Return the filenames."""
        prof = self.prof
        cfg = self._host_config
        flashcoll = prof.get_type('flash')
        assert len(flashcoll) > 0
        flash = flashcoll[0]
        self.run.MkDir(flash.repr(), niverr='SILENT', verbose=True)
        df = {}
        for typ in ('output', 'error', 'export'):
            fname = FileName(self.flash(typ))
            if not is_localhost2(self.host):
                fname.user = prof['username'][0]
                fname.host = prof['serveur'][0]
            else:
                fname.path = osp.join(get_home_directory(), fname.path)
            df[typ] = fname
        if cfg['result_on_client']:
            lf = [fname.repr() for fname in list(df.values())]
            self.run.Copy(flash.path, niverr='<A>_ALARM', *lf)
        else:
            cmd = 'mv -f %s %s'
            for fname in list(df.values()):
                self.run.Shell(cmd % (fname.path, flash.path),
                    mach=self.prof['serveur'][0], user=prof['username'][0])
        return df
