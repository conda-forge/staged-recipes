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
This module defines the Dispatcher class.
"""

import os
import traceback
from queue import Queue, Empty

try:
    import threading as _threading
except ImportError:
    import dummy_threading as _threading


Lock  = _threading.Lock
RLock = _threading.RLock


def is_main_thread():
    """Tell if current thread is the main thread.
    """
    return _threading.currentThread().getName() == "MainThread"


class TaskAbort(Exception):
    """Exception to abort execution of all workers.
    """
    def __init__(self, reason, result=None):
        self.reason = reason          # reason (text)
        if result is None:
            result = []
        self.current_result = result  # result of tasks already done


class Task:
    """Task object (will be dispatched in different thread).
    """
    def __init__(self, **kwargs):
        """Constructor - initialization : store kwargs items as attributes.
        Attributes 'OUT' should also be initialized.
        """
        self.queue = None
        self.done  = []
        self.done_lock = Lock()
        for k, v in list(kwargs.items()):
            setattr(self, k, v)
        # how many items treated at each call
        if getattr(self, 'nbmaxitem', None) is None:
            self.nbmaxitem = 1

    def execute(self, item, **kwargs):
        """Function called for each item of the stack
        (up to 'nbmaxitem' at each called).
        Warning : 'execute' should not modify attributes.
        """
        raise NotImplementedError('must be overridden in a subclass')

    def result(self, **kwargs):
        """Function called after each task to treat results of 'execute'.
        Arguments are 'execute' results + keywords args.
        'result' is called thread-safely, so can store results in attributes.
        """
        raise NotImplementedError('must be overridden in a subclass')

    def queue_get(self):
        """Get an item from the queue.
        """
        return self.queue.get_nowait()

    def queue_put(self, item):
        """Re-put an item into the queue.
        """
        self.queue.put_nowait(item)

    def is_queue_empty(self):
        """Return True if the queue is empty, False otherwise (not reliable!).
        """
        return self.queue.empty()

    def is_done(self, item):
        """Store item as done.
        """
        self.done_lock.acquire()
        self.done.append(item)
        nb = len(self.done)
        self.done_lock.release()
        return nb


class Dispatcher(object):
    """Execute a function in parallel.
    """
    result_lock = None
    WorkerClass = None

    def __init__(self, l_stack, task, numthread=1):
        """Execute in numthread separated threads (in parallel) using numthread Worker :

            for value in l_stack:
                out = task.execute(value)
                task.result(out) # vars_out allows to store "global" result.
        """
        queue = NumQueue()               # job queue
        if numthread > 1:
            Dispatcher.WorkerClass = ThreadWorker
        else:
            Dispatcher.WorkerClass = SequentialWorker
        Dispatcher.WorkerClass.numthread = 0   # thread creation count
        self.l_thread = []               # threads
        Dispatcher.result_lock = Lock()

        assert isinstance(task, Task), "'task' argument must be a Task instance !"

        # fill the queue
        for item in l_stack:
            queue.put(item)
        nbitem = len(l_stack)
        task.nbitem   = nbitem
        task.nbthread = numthread
        task.queue    = queue
        # spawn threads
        for i in range(numthread):
            t = Dispatcher.WorkerClass(task, i)
            self.l_thread.append(t)
            t.start()
        # wait for threads to finish
        for t in self.l_thread:
            t.join()

    def store_result(func, args, **kwargs):
        """Store/print result from threads.
        """
        Dispatcher.result_lock.acquire()
        nb = 1
        if type(kwargs['itemid']) in (list, tuple):
            nb = len(kwargs['itemid'])
        Dispatcher.WorkerClass.done += nb
        tberr = None
        try:
            func(done=Dispatcher.WorkerClass.done, *args, **kwargs)
        except Exception:
            tberr = traceback.format_exc()
        Dispatcher.result_lock.release()
        if tberr:
            raise TaskAbort(tberr)
    store_result = staticmethod(store_result)

    def report(self):
        """Report.
        """
        tot = 0
        occ = []
        txt = []
        for t in self.l_thread:
            thr_id, nb = t.report()
            tot += nb
            occ.append((thr_id, nb))
        for thr_id, nb in occ:
            txt.append('Thread %3d visited %6d times - %3d%%' \
                % (thr_id, nb, int(100.*nb/max(tot, 1))))
        txt.insert(0, 'Dispatcher report - %6d calls' % tot)
        return os.linesep.join(txt)


class Worker:
    """Worker for sequential execution.
    """
    numthread = 0                        # thread creation count
    done      = 0                        # global number of completed tasks

    def __init__(self, task, threadid):
        self.queue = task.queue           # Queue of sorting jobs to do
        Worker.numthread += 1             # update count of created threads
        self.threadid = threadid          # unique id of this thread
        self.loop = 0                     # work done by thread
        self.task = task

    def run(self):
        """Thread loops taking jobs from queue until none are left.
        """
        while True:
            l_item, l_ids = [], []
            is_empty = False
            for ibid in range(self.task.nbmaxitem):
                try:
                    # get job, Queue handles the locks for us
                    iid, item = self.queue.get_nowait()
                    l_item.append(item)
                    l_ids.append(iid)
                except Empty:
                    is_empty = True
            if self.task.nbmaxitem == 0:
                is_empty = self.queue.empty()
            # no more item in queue
            if is_empty:
                break
            if self.task.nbmaxitem == 1:
                l_item = l_item[0]
                l_ids  = l_ids[0]

            self.loop += 1
            success = False
            result = []
            try:
                # call the function
                result = self.task.execute(l_item, threadid=self.threadid, itemid=l_ids)
                success = True
            except TaskAbort as err:
                print('Interruption : %s' % err.reason)
                result = err.current_result
            except Exception as err:
                print('EXCEPTION (task.execute) :\n%s' % traceback.format_exc())
            if result:
                try:
                    Dispatcher.store_result(self.task.result, result,
                                                    threadid=self.threadid,
                                                    itemid=l_ids)
                except TaskAbort as err:
                    print('EXCEPTION (task.result) :\n%s' % err.reason)
                    success = False
            if not success:
                # Empty the queue to interrupt all workers
                self.queue.clear()
                break

    def report(self):
        """Report."""
        return (self.threadid, self.loop)


class ThreadWorker(Worker, _threading.Thread):
    """Worker thread for parallel execution.
    """
    def __init__(self, task, threadid):
        Worker.__init__(self, task, threadid)
        _threading.Thread.__init__(self)


class SequentialWorker(Worker):
    """Worker thread for sequential execution.
    """
    def start(self):
        """Fake start function."""
        self.run()

    def join(self):
        """Fake start function."""


class NumQueue(Queue):
    """Similar to a Queues object with a counter of extracted elements.
    """
    def __init__(self, **kwargs):
        """Initializations
        """
        Queue.__init__(self, **kwargs)
        self.counter = 0

    def _get(self):
        """Get an item from the queue
        """
        self.counter += 1
        return self.counter, self.queue.popleft()

    def _put(self, item):
        """Put an item into the queue
        """
        self.queue.append(item)

    def clear(self):
        """Empty the queue.
        """
        self.counter = 0
        self.queue.clear()
