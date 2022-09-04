# -*- coding: utf-8 -*-
#pylint: disable-msg=R0902

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
Allow to manage jobs on several hosts according to the available
cpu and memory resources.
"""

import os
import traceback
from pprint import pprint, pformat

from asrun.common.i18n   import _
from asrun.thread        import Lock, Task, Dispatcher
from asrun.system        import local_host
from asrun.common_func   import get_tmpname
from asrun.common.utils  import now
from asrun.common.rcfile import parse_config


_DBG_TRI   = False
_DBG_CRIT  = False
_DBG_ALLOC = False


def isnum(val):
    """Return True if `val` is a number."""
    return type(val) in (int, int, float)


# constants
NORESOURCE, ALLOCATED, OVERLIMIT = [9001, 9002, 9003]


class ResourceManagerError(Exception):
    """Local exception"""


class Resource(object):
    """Object that contains the resource values."""

    def __init__(self, data):
        self._data = data

    def __contains__(self, key):
        return key in self._data

    def __getitem__(self, key):
        return self._data[key]

    def get(self, key, default=None):
        """Access a value by key, or default."""
        return self._data.get(key, default)

    def items(self):
        """Return a view on data items."""
        return self._data.items()

    def __lt__(self, other):
        """Sort resources, "<" means "more available"."""
        left = sorted(list(self._data.items()))
        right = sorted(list(other._data.items()))
        return left < right


class ResourceManager:
    """Class to manage resources to run a lot of calculations of several hosts.
    """
    lock = Lock()

    def __init__(self, hostinfo):
        """Initializations.
        """
        self.hostinfo = hostinfo.copy()
        self.all_hosts = list(self.hostinfo.keys())

        self.d_crit = {# numkey,   default, reverse order
            # criteria
            'cpurun' : ('000_cpurun',  0,     False, ),
            'memrun' : ('010_memrun',  0,     False, ),
            # characteristics of hosts (constant)
            'mem'    : ('101_mem',     0,     True,  ),
            'cpu'    : ('102_cpu',     0,     True,  ),
            'nomjob' : ('998_job',    '',     False, ),
            'host'   : ('999_host',   '',     False, ),
            'user'   : ('999_user',   '',     False, ),
        }
        self.l_crit = [(v[0], v[2]) for v in list(self.d_crit.values())]
        self.l_crit.sort()
        self.job_keys = [k for k, v in list(self.d_crit.items()) if v[0] > '100_']
        # build the list of all infos
        self.infos = []
        self.limit = {}
        # to store host availability
        self.host_connection = {}
        for host, info in list(self.hostinfo.items()):
            self.host_connection[host] = True
            info['host'] = host
            dico = {}
            for crit, val in list(self.d_crit.items()):
                numkey, default, reverse = val
                dico[numkey] = info[crit] = info.get(crit, default)
                if numkey > '100_' and numkey < '900_' \
                and ( \
                    self.limit.get(crit) is None or (reverse and self.limit[crit] < dico[numkey]) \
                    or  (not reverse and self.limit[crit] > dico[numkey]) \
                ):
                    self.limit[crit] = dico[numkey]
            self.infos.append(dico)
        # to store job parameters
        self.history = {}

    def get(self, host, key, default=None):
        """Return a current value.
        """
        res = default
        if self.d_crit[key][0] > '100_':
            res = self.hostinfo[host][key]
        else:
            nkey = self.d_crit[key][0]
            for info in self.infos:
                if info['999_host'] == host:
                    res = info[nkey]
                    break
        return res

    def set(self, host, key, value):
        """Set a value.
        """
        done = False
        if self.d_crit[key][0] > '100_':
            raise ResourceManagerError("can not be changed : '%s'" % key)
        else:
            nkey = self.d_crit[key][0]
            for info in self.infos:
                if info['999_host'] == host:
                    info[nkey] = value
                    done = True
        if not done:
            raise ResourceManagerError("can't set '%s'" % key)

    def add(self, host, key, value):
        """Add 'value' to the current value.
        """
        current = self.get(host, key)
        self.set(host, key, current + value)

    def sub(self, host, key, value):
        """Substract 'value' to the current value.
        """
        current = self.get(host, key)
        self.set(host, key, current - value)

    def store_job(self, host='unknown', **kwjob):
        """Store 'kwjob' in history.
        """
        if host is None:
            return
        dico = kwjob.copy()
        dico['host'] = host
        dico['allocated'] = now(datefmt="%a")
        self.history[kwjob['nomjob']] = dico

    def get_job(self, jobname):
        """Get 'jobname' from history.
        """
        dico = self.history.get(jobname)
        if dico is None:
            return {}
        dico['released'] = now(datefmt="%a")
        return dico.copy()

    def get_history(self):
        """Return a copy of the jobs's 'history'.
        """
        dico = self.history.copy()
        return dico

    def action(self, what, *args, **kwargs):
        """Run safely a method which access to infos attribute.
        """
        result = None
        self.lock.acquire()
        tberr = None
        try:
            result = getattr(self, what)(*args, **kwargs)
        except Exception:
            tberr = traceback.format_exc()
        self.lock.release()
        if tberr:
            raise ResourceManagerError(tberr)
        return result

    def get_first(self, values=None):
        """Return the most available host.
        """
        if values is None:
            values = self.infos[:]
        if len(values) == 0:
            return {}

        values = [Resource(dic) for dic in values]
        for crit, rev in self.l_crit:
            values.sort(reverse=rev)
            if _DBG_TRI:
                print(crit)
                pprint(values)
            val0 = values[0][crit]
            new = [values[0], ]
            for info in values[1:]:
                if info[crit] != val0:
                    break
                new.append(info)
            values = new
            if len(values) == 1:
                break
        if _DBG_TRI:
            print('--- FIN ---')
            pprint(values)
        return dict([(k, v) for k, v in values[0].items()])

    def is_connected(self, host):
        """Tell if 'host' is connected.
        """
        return self.host_connection[host]

    def get_all_connected_hosts(self):
        """Return all connected hosts.
        """
        return [h for h in self.all_hosts if self.is_connected(h)]

    def suitable_host(self, **kwjob):
        """Limit infos to capable hosts.
        """
        values = []
        for info in self.infos:
            if not self.is_connected(info[self.d_crit['host'][0]]):
                continue
            isok = True
            for par, val in list(kwjob.items()):
                if not self.isok(par, val, info):
                    isok = False
                    break
            if isok:
                values.append(info)
        return values

    def available_host(self, **kwjob):
        """Return the most available host accepting job parameters.
        """
        if _DBG_CRIT:
            print('job parameters : ', end=' ')
            pprint(kwjob)
        values = self.suitable_host(**kwjob)
        if _DBG_CRIT:
            print('%d suitable hosts : %s' \
                % (len(values), [info[self.d_crit['host'][0]] for info in values]))
        avail = self.get_first(values)
        return avail

    def isok(self, key, value, info):
        """Tell if 'value' is under the limit vs 'info[par]'.
        """
        if not key in self.job_keys:
            return False
        val_ref = info[self.d_crit[key][0]]
        if key + 'run' not in self.d_crit:
            return True
        val_run = info[self.d_crit[key + 'run'][0]]
        ok = (value + val_run) <= val_ref
        if _DBG_CRIT:
            rep = '-'
            if ok:
                rep = 'ok'
            print('%-2s host=%-24s para=%-4s allocated=%-4s requested=%-4s ref=%-4s' % \
                (rep, info[self.d_crit['host'][0]], key, val_run, value, val_ref))
        return ok

    def CheckHosts(self, run, silent=False, numthread="auto"):
        """Check connection to known hosts, update host_connection attribute.
        """
        try:
            numthread = int(numthread)
        except (TypeError, ValueError):
            numthread = run.GetCpuInfo('numthread')
        if numthread > 1:
            numthread = numthread * 8
        task = CheckHostsTask(run=run, silent=silent, success_connection=self.host_connection)
        users = [self.get(h, 'user') for h in self.all_hosts]
        couples = list(zip(users, self.all_hosts))
        check = Dispatcher(couples, task, min(numthread, len(couples)))
        run.DBG(check.report())
        nbok = len([host for host, success in list(self.host_connection.items()) if success])
        return nbok, len(self.all_hosts)


    def Request(self, run=None, **kwjob):
        """Ask for an available host and block resources.
        """
        info = self.action('available_host', **kwjob)
        host = info.get(self.d_crit['host'][0], None)
        if _DBG_ALLOC:
            print('job allocated on %s : %s' % (host, pformat(kwjob)))
        if host is not None:
            status = ALLOCATED
            for key in self.job_keys:
                if isnum(kwjob.get(key)):
                    self.action('add', host, key + 'run', kwjob[key])
        else:
            status = NORESOURCE
            for key, lim in list(self.limit.items()):
                if kwjob.get(key) and (\
                    (self.d_crit[key][2]     and kwjob[key] > lim) or \
                    (not self.d_crit[key][2] and kwjob[key] < lim) ):
                    status = OVERLIMIT
                    if run:
                        run.DBG("OVERLIMIT %s : requested = %s  limit = %s  (reverse = %s)" \
                            % (key, kwjob[key], lim, self.d_crit[key][2]))
                    break
        self.action('store_job', host, **kwjob)
        if _DBG_ALLOC:
            print(self.Load())
        return host, status

    def Free(self, jobname):
        """Free job resources on 'host'.
        """
        kwjob = self.action('get_job', jobname)
        if not kwjob:
            return
        host = kwjob['host']
        ddbg = {}
        for key in self.job_keys:
            if isnum(kwjob.get(key)):
                self.action('sub', host, key + 'run', kwjob[key])
                ddbg[key] = kwjob[key]
        if _DBG_ALLOC:
            print('job released : %s' % (pformat(ddbg)))

    def repr_history(self):
        """Return jobs's history.
        """
        dico = self.action('get_history')
        ljob = [(v['allocated'], k) for k, v in list(dico.items())]
        ljob.sort()
        head = '%s %s %s %s %s %s' % (_("job").center(14), _("host").center(16),
                                                _("started").center(12), _("cpu").rjust(6),
                                                _("memory").rjust(6), _("ended").rjust(12))
        fmt  = '%(job_)-14s %(host_)-16s %(allocated)12s %(cpu)6d %(mem)6d %(released)12s'
        dini = { 'job_' : '', 'host_' : '', 'allocated' : '', 'cpu' : 0,
                 'mem' : 0, 'released' : '' }
        txt = [head, ]
        for dummy, job in ljob:
            dval = dini.copy()
            dval.update(dico[job])
            dval.update({ 'job_' : job[:14], 'host_' : dval['host'][:16] })
            txt.append(fmt % dval)
        return os.linesep.join(txt)

    def Load(self):
        """Return current load.
        """
        infos = self.infos[:]
        lkey = ['cpu', 'mem']
        head = '    host      cpu    mem'
        fmt = '%(host_)-16s %(cpu)6d %(mem)6d'
        txt = [head, ]
        for info in infos:
            dval = { 'host_' : info[self.d_crit['host'][0]][:16] }
            for k in lkey:
                dval[k] = info[self.d_crit[k + 'run'][0]]
            txt.append(fmt % dval)
        return os.linesep.join(txt)

    def GetConfig(self, host):
        """Return the configuration of 'host'.
        """
        return self.hostinfo.get(host, {}).copy()

    def get_sum(self, key):
        """Return the sum of a resource.
        """
        return sum([self.get(host, key, 0) for host in self.get_all_connected_hosts()])

    def __repr__(self):
        return self.hostinfo_repr()

    def hostinfo_repr(self, title=""):
        """Return a hostfile representing the content of the 'hostinfo' attribute.
        """
        if not title:
            title = "from ResourceManager object"
        content = ["# GENERATED %s - %s" % (title, now())]
        for mach, res in list(self.hostinfo.items()):
            cpu = res["cpu"]
            mem = res["mem"]
            if cpu == mem == 0:
                content.append("# %s is not responding" % mach)
            else:
                content.append("[%s]" % mach)
                if cpu > 0:
                    content.append("cpu=%d" % cpu)
                if mem > 0:
                    content.append("mem=%d" % mem)
            content.append("")
        return os.linesep.join(content)


class PureLocalResource(ResourceManager):
    """Derived class to run only on local host.
    """
    def __init__(self, run):
        """Initialization using AsterRun object."""
        cpu  = run.GetCpuInfo('numcpu')
        mem  = run.GetMemInfo('memtotal') or 9999999
        dico = { local_host : { 'host' : local_host, 'cpu' : cpu, 'mem' : mem }}
        ResourceManager.__init__(self, hostinfo=dico)



class CheckHostsTask(Task):
    """Task to check a host.
    """
    # declare attrs
    run = None
    silent = False
    success_connection = {}

    def execute(self, item, **kwargs):
        """Function called for each item of the stack
        (up to 'nbmaxitem' at each called).
        Warning : 'execute' should not modify attributes.
        """
        user, host = item
        success = False
        if self.run.Ping(host):
            iret, output = self.run.Shell('echo hello', mach=host, user=user)
            if output.find('hello') >= 0:
                self.run.DBG("CheckHosts success on %s" % host)
                success = True
        return host, success


    def result(self, host, success, **kwargs):
        """Function called after each task to treat results of 'execute'.
        Arguments are 'execute' results + keywords args.
        'result' is called thread-safely, so can store results in attributes.
        """
        if not self.silent:
            print(_("checking connection to %s... ") % host, end="")
            if success:
                print(_("connected"))
            else:
                print(_("failed"))
        self.success_connection[host] = success



def get_hostrc(run, prof):
    """Return hostrc object from profile or config.
    """
    mode = prof['mode'][0]
    run.DBG('From profile', prof.Get('D', 'hostfile'))
    run.DBG('From asrun resources', run.get('%s_distrib_hostfile' % mode))
    hostrc = None
    if prof.Get('D', 'hostfile'):
        fhost = prof.Get('D', 'hostfile')[0]['path']
        if run.IsRemote(fhost) or True:
            tmphost = get_tmpname(run, run['tmp_user'], basename='hostfile')
            run.ToDelete(tmphost)
            iret = run.Copy(tmphost, fhost)
            fhost = tmphost
        else:
            fhost = run.PathOnly(fhost)
    elif run.get('%s_distrib_hostfile' % mode):
        fhost = run['%s_distrib_hostfile' % mode]
    else:
        fhost = None
    if fhost:
        hostinfo = parse_config(fhost)
        run.DBG('hostinfo : %s' % hostinfo, all=True)
        hostrc = ResourceManager(hostinfo)
    else:
        hostrc = PureLocalResource(run)
    run.DBG(hostrc)
    return hostrc
