# -*- coding: utf-8 -*-

"""
Facility to manipulate lock files
"""

import os
import os.path as osp
import time
import logging
from hashlib import sha1


logging.basicConfig(format='%(asctime)s.%(msecs)03d %(levelname)-8s %(message)s',
                    datefmt='%H:%M:%S',
                    level=logging.ERROR)
log = logging.getLogger('lockfile.log')


class LockError(Exception):
    """Error raised when locking file."""
    def __init__(self, msg):
        self.msg = msg


class LockedFile(object):
    """Class to use a lock file transparently to write into a file."""

    def __init__(self, filename, mode='a+b',
                       max_attempt=50, interval=0.2,
                       lockdir=None,
                       info=0):
        """Initialization.
            mode : mode used to open file but how can it be different of 'a'.
            max_attempt : number of attempts to lock repositories list
            interval : delay between two attempts
            info : information level, 0 (silent), 1 (info), 2 (debug)
        """
        self._fname = filename
        self._mode = mode
        rootname = sha1(self._fname.encode()).hexdigest() + '_' + osp.basename(self._fname) + '.lock'
        if lockdir is None:
            lockdir = osp.dirname(self._fname)
        self._lockfile = osp.join(lockdir, rootname)
        self._locked = False
        self._max_attempt = max_attempt
        self._interval = interval
        #if os.path.exists(self._lockfile):
            #os.remove(self._lockfile)
        if info >= 2:
            log.setLevel(logging.DEBUG)
        elif info >= 1:
            log.setLevel(logging.INFO)
        log.debug("locked file '%s' created, mode '%s'", self._fname, self._mode)
        log.debug("lock file is '%s'" % self._lockfile)


    def write(self, *args):
        """Equivalent of file.write"""
        try:
            self._acquire()
        except LockError as err:
            log.info("%s: write cancelled", err.msg)
            return
        fobj = open(self._fname, self._mode)
        fobj.write(*args)
        fobj.close()
        self._release()


    def close(self):
        """In case it has not been done."""
        self._release()


    def _acquire(self):
        """Acquire a lock."""
        if self._locked:
            log.info("'%s' is already locked", self._fname)
            return
        for i in range(self._max_attempt):
            if i > 0:
                time.sleep(self._interval)
            try:
                fd = os.open(self._lockfile, os.O_RDWR | os.O_CREAT | os.O_EXCL, 0o644)
                os.write(fd, "lock file of %s" % self._fname)
                os.close(fd)
                log.debug("'%s' locked", self._fname)
                self._locked = True
                return
            except OSError:
                log.info("'%s' already locked, wait for %s s", self._fname, self._interval)
                pass
        raise LockError("unable to lock '%s'" % self._fname)


    def _release(self):
        """Release current lock."""
        if not self._locked:
            log.info("'%s' is not locked !" % self._fname)
            return
        try:
            os.remove(self._lockfile)
        except OSError as err:
            log.info("can not remove '%s', reason: %s" % (self._lockfile, err))
            pass
        self._locked = False
        log.debug("'%s' released", self._fname)


if __name__ == "__main__":
    import sys
    fname = "/tmp/testlock"
    if len(sys.argv) > 1:
        fname = sys.argv[1]
    def message():
        ct =  time.time()
        msecs = (ct - int(ct)) * 1000
        txt = "%s.%03d written by process %s\n" \
            % (time.strftime('%H:%M:%S'), msecs, os.getpid())
        return txt

    lof = LockedFile(fname, 'a', info=2)
    for i in range(100):
        lof.write(message())
