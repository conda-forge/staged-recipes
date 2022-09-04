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
Some utilities needing some asrun objects to be initialized.
"""
#...but must not require import of other asrun modules

import os
import os.path as osp
import re

from asrun.common.i18n import _
from asrun.core import magic
from asrun.common.utils import get_tmpname_base
from asrun.common.rcfile import get_nodepara
from asrun.common.sysutils import is_localhost, safe_pathname, same_hosts
from asrun.system_command import COMMAND as CMD


def get_tmpname(run, dirname=None, basename=None, node=None, pid=None):
    """Return a name for a temporary directory (*not created*)
    of the form : 'dirname'/user-machine-'basename'.'pid'
    Default values :
        dirname  = run['rep_trav']   from config file
        basename = 'tmpname-' + date
        pid      = run['num_job']
    """
    user, host = run.system.getuser_host()
    node = node or host
    dirname  = dirname or get_nodepara(node, 'rep_trav', run['rep_trav'])
    pid = pid or run['num_job']
    return get_tmpname_base(dirname, basename, user, node, pid)


def get_devel_param(run):
    """Return user/server on the main server.
    """
    user = run['devel_server_user']
    mach = run['devel_server_ip']
    if user in (None, ''):
        run.Mess(_("remote connection to '%s' may fail :%s" \
                   "'devel_server_user' not defined in '%s'") \
                % (mach, os.linesep, run.user_rc), '<A>_ALARM')
    return user, mach


def flash_filename(flash, jobname, jobid, typ, mode="interactif"):
    """Return the filename of a file in 'flasheur'."""
    d_ext = { 'output' : 'o', 'error' : 'e', 'export' : 'p',
             'script' : 'u', 'diag'  : mode[0], '' : '' }
    ext = d_ext.get(typ, 'X')
    fname = osp.join(flash, '%s.%s%s' % (jobname, ext, jobid))
    return fname


def edit_file(run, fname):
    """Call the editor on the filename given."""
    # get editor command line
    edit = run.get('editor')
    # backwards compatibility
    if not edit:
        edit = run['editeur']
    cmd = '%s %s' % (edit, fname)
    kret, out = run.Shell(cmd, bg=True)


def is_localhost2(host, ignore_domain=True, user=""):
    """Return True if 'host' is the same machine as localhost.
    Same as sysutils.is_localhost but check also hostid."""
    result = is_localhost(host, ignore_domain, user)
    # test using hostid
    if not result and magic.run is not None:
        local_hostid = get_hostid()
        hostid = get_hostid(host, user)
        result = hostid == local_hostid
        magic.log.debug('is_localhost %s (%s) : %s', host, hostid, result)
    return result


def same_hosts2(host1, host2, user1='', user2=''):
    """Tell if host1 and host2 are the same host.
    Same as sysutils.same_hosts but check also hostid."""
    result = same_hosts(host1, host2)
    # test using hostid
    if not result and magic.run is not None:
        hostid1 = get_hostid(host1, user1)
        hostid2 = get_hostid(host2, user2)
        result = hostid1 == hostid2 and hostid1 is not None
        magic.log.debug("are '%s' and '%s' the same host ? %s", host1, host2, result)
    return result


_cache_hostid = {}

# prefer use uuid.getnode() on python >= 2.5
def get_hostid(host='', user=''):
    """Return hostid of `host`."""
    global _cache_hostid
    key = host or 'localhost'
    hostid = _cache_hostid.get(key)
    if hostid is None and key not in _cache_hostid:
        hostid = _get_remote_hostid(host, user)
        _cache_hostid[key] = hostid
    magic.log.debug("hostid('%s')=%s using user '%s'" % (host, hostid, user))
    return hostid

_mark_recurs = None
def _get_remote_hostid(host, user):
    """How to compute 'hostid'."""
    global _mark_recurs
    hostid = None
    if _mark_recurs is not None:
        return hostid
    _mark_recurs = "running"
    if CMD['hostid'] == 'hostid':
        iret, out = magic.run.Shell('hostid', mach=host, user=user)
        if iret == 0:
            hostid = out.strip()
    elif CMD['hostid'] == 'ifconfig':
        iret, out = magic.run.Shell('/sbin/ifconfig', mach=host, user=user)
        if iret == 0:
            readdr = re.compile('(?:HWaddr|ether|adr inet6:) +([0-9:a-z/]+)', re.I)
            mat = readdr.search(out, re.I)
            if mat:
                hostid = mat.group(1)
    elif CMD['hostid'] == 'ipconfig':
        iret, out = magic.run.Shell('ipconfig', mach=host, user=user)
        if iret == 0:
            readdr = re.compile(r': *([0-9\-a-z]+\-[0-9\-a-z]+)', re.I)
            mat = readdr.search(out, re.I)
            if mat:
                hostid = mat.group(1)
    else:
        assert False, "invalid 'hostid' command in system_command !"
    # if iret != 0, store None to skip this host the next time.
    _mark_recurs = None
    return hostid


# transitional function (will be replaced by configuration object)
def get_limits(run, mode):
    """Return mode + '_memmax/_tpsmax/_nbpmax/_mpi_nbpmax' from configuration
    or by automatically estimating them."""
    lkey = ('memmax', 'tpsmax', 'nbpmax', 'mpi_nbpmax')
    dkey = dict([(k, mode + '_' + k) for k in lkey])
    dres = {}
    for key in list(dkey.values()):
        dres[key] = run.get(key)
    key = dkey['tpsmax']
    if dres[key] is None:
        dres[key] = "9999:00:00"
    if dres[dkey['memmax']] is None:
        dres[dkey['memmax']] = run.GetMemInfo('memtotal') or 9999999
    if dres[dkey['nbpmax']] is None:
        dres[dkey['nbpmax']] = run.GetCpuInfo('numcpu')

    key = dkey['mpi_nbpmax']
    if dres[key] is None:
        dres[key] = dres[dkey['nbpmax']]
    run.DBG('Limits returned :', dres)
    return dres

# for backward compatibility
from asrun.backward_compatibility import get_hostrc
