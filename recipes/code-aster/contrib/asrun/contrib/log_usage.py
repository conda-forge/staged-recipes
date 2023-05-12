# -*- coding: utf-8 -*-

import os
import os.path as osp
import time

from asrun.core import magic
from asrun.common.lockfile import LockedFile

UNKNOWN = 'unknown'


def log_usage_version(filename, prof):
    """Log the version used."""
    format = "%(start)s %(user)-10s %(fromhost)-20s %(version)-12s " \
             "%(service)-10s %(jobname)-15s %(memjob)9.1f %(timejob)9d %(mode)-10s " \
             "%(mpi_nbcpu)2d %(mpi_nbnoeud)2d %(ncpus)2d"

    start = time.strftime('%Y/%m/%d %H:%M:%S')
    user = prof['username'][0] or UNKNOWN
    service = prof['service'][0] or UNKNOWN
    fromhost = (prof['mclient'][0] or UNKNOWN)[:20]
    version = osp.basename(prof['version'][0] or UNKNOWN)
    jobname = (prof['nomjob'][0] or UNKNOWN)[:15]
    mode = prof['mode'][0] or UNKNOWN
    try:
        memjob = (float(prof['memjob'][0] or 0.) / 1024.) # MB
    except:
        memjob = 0.
    try:
        timejob = (float(prof['tpsjob'][0] or 0.) * 60.)  # s
    except:
        timejob = 0.
    try:
        ncpus = int(prof['ncpus'][0] or 0)
    except:
        ncpus = 0
    try:
        mpi_nbcpu = int(prof['mpi_nbcpu'][0] or 0)
    except:
        mpi_nbcpu = 0
    try:
        mpi_nbnoeud = int(prof['mpi_nbnoeud'][0] or 0)
    except:
        mpi_nbnoeud = 0

    lockdir = '/tmp'
    if magic.run:
        lockdir = magic.run['proxy_dir']
    line = format % locals()
    file = LockedFile(filename, mode='a+b', max_attempt=25, info=0, lockdir=lockdir)
    file.write(line.strip() + os.linesep)


def log_usage_version_unfail(*args):
    """Log the version used (will never fail)."""
    try:
        return log_usage_version(*args)
    except:
        pass


if __name__ == '__main__':
    import getpass
    from asrun.profil import AsterProfil

    #filename = "/aster/log/usage_version.log"
    filename = magic.run['log_usage_version']
    prof = AsterProfil()
    prof['version'] = 'STA10'
    prof['mclient'] = 'claut682.der.edf.fr'
    prof['username'] = getpass.getuser()
    prof['nomjob'] = 'etude_avec_contact'
    prof['mode'] = 'interactif'
    log_usage_version(filename, prof)
