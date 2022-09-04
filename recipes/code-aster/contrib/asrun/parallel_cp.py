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

"""parallel_copy [options] tracker_path source_directory destination_directory

    tracker_path           : This directory MUST be shared by all nodes.
                                    It stores which sources are available.
    source_directory      : The directory to copy
    destination_directory : (local) directory in which content will be copied.

This module allows to copy a source directory into multiple destinations.
"""

__sup_doc__ = """This uses a (very simplified*) peet-to-peer files sharing : each destination
becomes a new seed for the others.

(*) - use standard cp/rcp/scp commands,
    - does not share blocks of files but only the entire source directory.

The number of available seeds after n cycles = (leech_limit + 1)^n

Example : For copying a directory on 100 nodes if a unique copy
          takes 10 s, the copy will be completed after 70 s or 50 s
          (leech_limit=1 or 2).
  #cycle  leech_limit=1  leech_limit=2
     1            2             3
     2            4             9
     3            8            27
     4           16            81
     5           32           243(*)
     6           64           729
     7          128(*)       2187
     8          256          6561
     9          512         19683
"""


import os
import pprint
import time
from socket   import gethostname
from optparse import OptionParser

from asrun.common.i18n import _
from asrun.common.utils import now

DEBUG = False
DEBUG_copy_delay = 0.

default_leech_limit = 2


class CopyError(Exception):
    """Local exception"""


class PARALLEL_COPY:
    """Copy /dirsrc into /dest
    - get from 'tracker' an available 'repository'.
    - copy repository:/dirsrc into /dest
    - when done, adds 'leech:/dest' in the repositories list in '/dirsrc/repositories'

    number of available source after n cycles = (p + 1)^n
    with p = number of connections to a source
    """
    max_attempt_src  = 300     # number of attempts to get a source
    interval_src     = 1.0     # delay between two attempts
    max_attempt_lock = 100     # number of attempts to lock repositories list
    interval_lock    = 0.5     # delay between two attempts


    def __init__(self, tracker, master, dest, leech_limit, verbose=False, run=None):
        """Initializations
        """
        self.tracker = os.path.normpath(os.path.realpath(tracker))
        if not os.path.exists(self.tracker):
            try:
                os.makedirs(self.tracker)
            except (OSError, IOError):
                pass
        self.master  = os.path.normpath(os.path.realpath(master))
        self.dest    = os.path.normpath(os.path.realpath(dest))
        self.lock    = None
        self.leech   = '%s:%s' % (gethostname() , self.dest)
        self.leech_limit = leech_limit
        assert self.leech_limit < 5, \
            "It seems dangerous and inefficient to have too much leechs per seed."
        self.verbose = verbose
        # use functions from AsterRun object
        self.run = run


    def copy(self, src, dest):
        """Copy 'src' file or directory to 'dest'.
        """
        opts = {}
        if self.verbose:
            print(_('(parallel_copy) - destination : %s - seed : %s')  % (self.dest, src))
        if self.verbose:
            print(_('   COPY %s into %s') % (src, dest))
            opts['verbose']     = True
            opts['alt_comment'] = False
        if self.run is None:
            src  = src.split(':')[-1]
            dest = dest.split(':')[-1]
            iret = os.system('cp -rp %s %s' % (src, dest))
        else:
            iret = self.run.Copy(dest, src, **opts)
        if DEBUG_copy_delay > 0.:
            time.sleep(DEBUG_copy_delay)
        return iret


    def repo_filename(self):
        """Return repositories list filename
        """
        return os.path.join(self.tracker, 'repositories')


    def lock_filename(self):
        """Return lock filename
        """
        return os.path.join(self.tracker, 'lock')


    def acquire(self):
        """Acquire a lock.
        """
        if self.lock is not None:
            return
        flock = self.lock_filename()
        for i in range(self.max_attempt_lock):
            if i > 0:
                time.sleep(self.interval_lock)
            try:
                fd = os.open(flock, os.O_RDWR | os.O_CREAT | os.O_EXCL, 0o644)
                os.write(fd, self.leech)
                os.close(fd)
                if DEBUG:
                    print('        LOCKED (attempt %d) by %s' % (i+1, self.leech))
                self.lock = 'locked'
                return
            except OSError:
                pass
        raise CopyError(_('can not lock the repository (timeout after %0.f)') \
                % (self.max_attempt_lock * self.interval_lock))


    def release(self):
        """Release current lock.
        """
        if self.lock is None:
            raise CopyError(_('No lock to release'))
        flock = self.lock_filename()
        if DEBUG:
            print('      RELEASED by', self.leech)
        if os.path.exists(flock):
            os.remove(flock)
        self.lock = None


    def save_repository(self, d_repo):
        """Save the repositories_list into repositories file.
        """
        assert self.lock is not None
        with open(self.repo_filename(), 'w') as f:
            f.write("repository = %s" % pprint.pformat(d_repo))


    def read_repository(self):
        """Reads and returns the repositories list.
        """
        assert self.lock is not None
        d = {}
        with open(self.repo_filename()) as f:
            exec(compile(f.read(), self.repo_filename(), 'exec'), d)
        d_repo = d['repository']
        return d_repo


    def update_repository(self, repos):
        """Add some repositories to the list.
        """
        if not type(repos) in (list, tuple):
            repos = [repos,]
        self.acquire()
        d_repo = self.read_repository()
        for src in repos:
            d_repo[src] = min(d_repo.get(src, 0) + 1, self.leech_limit)
        self.save_repository(d_repo)
        self.release()


    def get_repository(self):
        """Ask 'tracker' for an available repository
        """
        src = ''
        for i in range(self.max_attempt_src):
            if i > 0:
                time.sleep(self.interval_src)
            self.acquire()
            repo = self.repo_filename()
            if not os.path.exists(repo):
                self.save_repository({ self.master : self.leech_limit})
            d_repo = self.read_repository()
            if len(d_repo) > 0:
                lval = [(v, k) for k, v in list(d_repo.items())]
                lval.sort()          # reverse=True does not exists in python < 2.4
                lval.reverse()
                disp, src = lval[0]
                if disp == 0:        # no source available
                    self.release()
                    continue
                d_repo[src] -= 1
                self.save_repository(d_repo)
                self.release()
                return src
            self.release()
        raise CopyError('no repository available in the delay (%.0f)' \
                % (self.max_attempt_src * self.interval_src))


    def start(self):
        """Start the copy
        """
        if self.verbose:
            print(_('(parallel_copy) - destination : %s - start time : %s') \
                % (self.dest, now(datefmt="")))
        # get a source
        src = self.get_repository()

        # copy
        if src == self.dest or src == self.leech:
            print(_('source and destination are identical'))
            return
        if DEBUG:
            spl = src.split(':')
            host_src = ''
            if len(spl) > 0:
                host_src = spl[0].split('.')[0] + ':'
            host_dest = gethostname().split('.')[0] + ':'
            print('GRAPH   "%s%s" -> "%s%s";' % (host_src, os.path.basename(src), host_dest, os.path.basename(self.dest)))
        if not os.path.exists(self.dest):
            os.makedirs(self.dest)
        iret = self.copy('%s/*' % src, self.dest)

        # remove repositories file in dest
        dest_repo = os.path.join(self.dest, os.path.basename(self.repo_filename()))
        if os.path.exists(dest_repo):
            os.remove(dest_repo)

        l_repo = [src,]
        l_repo.extend([self.leech,] * self.leech_limit)
        self.update_repository(l_repo)
        if self.verbose:
            print(_('(parallel_copy) - destination : %s  -  end time : %s') \
                % (self.dest, now(datefmt="")))


def estimate_num_cycle(num_dest, num_src=1, leech_limit=2):
    """Return the number of cycles needed."""
    from math import log, ceil
    ninf = ceil(log(1. * num_dest / num_src) / log(leech_limit + 1.))
    return ninf


def main():
    """Start"""
    # command arguments parser
    parser = OptionParser(usage=__doc__)
    parser.add_option('--with-as_run', dest='with_as_run',
            action='store_true', default=False,
            help="use as_run functions to allow remote copy")
    parser.add_option('--remote_copy_protocol', dest='remote_copy_protocol',
            action='store', default='RCP',
            help='remote protocol used to copy files and directories')
    parser.add_option('--remote_shell_protocol', dest='remote_shell_protocol',
            action='store', default='RSH',
            help='remote protocol used for shell commands')
    parser.add_option('--leech_limit', dest='leech_limit',
            action='store', default=default_leech_limit, metavar='NUM',
            help='maximum number of connections to each seed (default %d)' % default_leech_limit)
    parser.add_option('--silent', dest='verbose',
            action='store_false', default=True,
            help='run silently (do not print start/end time...)')
    parser.add_option('--long_help', dest='long_help',
            action='store_true', default=False,
            help='print complete help (with example) and exit')

    opts, l_args = parser.parse_args()

    if opts.long_help:
        parser.usage += __sup_doc__
        parser.print_help()
        parser.exit(1)

    if opts.with_as_run:
        from asrun.system import AsterSystemMinimal
        run = AsterSystemMinimal(remote_copy_protocol=opts.remote_copy_protocol,
                                            remote_shell_protocol=opts.remote_shell_protocol)
    else:
        run = None

    if len(l_args) == 0:
        parser.error('invalid arguments')

    copy = PARALLEL_COPY(leech_limit=opts.leech_limit, run=run, verbose=opts.verbose, *l_args)
    copy.start()


if __name__ == '__main__':
    main()
