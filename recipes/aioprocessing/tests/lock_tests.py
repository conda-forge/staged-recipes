import sys
import time
import asyncio
import unittest
import traceback

import aioprocessing
import aioprocessing.mp as multiprocessing
from aioprocessing.mp import Process, Event, Queue, get_all_start_methods

try:
    from aioprocessing.mp import get_context
except ImportError:

    def get_context(param):
        pass


from ._base_test import BaseTest, _GenMixin

MANAGER_TYPE = 1
STANDARD_TYPE = 2


def get_value(self):
    try:
        return self.get_value()
    except AttributeError:
        try:
            return self._Semaphore__value
        except AttributeError:
            try:
                return self._value
            except AttributeError:
                raise NotImplementedError


def do_lock_acquire(lock, e):
    lock.acquire()
    e.set()
    time.sleep(2)
    lock.release()


def sync_lock(lock, event, event2, queue):
    event2.wait()
    queue.put(lock.acquire(False))
    event.set()
    lock.acquire()
    lock.release()


class GenAioLockTest(BaseTest, _GenMixin):
    def setUp(self):
        super().setUp()
        self.Obj = aioprocessing.AioLock
        self.inst = self.Obj()
        self.meth = "coro_acquire"


class GenAioManagerLockTest(GenAioLockTest):
    def setUp(self):
        super().setUp()
        self.manager = aioprocessing.AioManager()
        self.Obj = self.manager.AioLock
        self.inst = self.Obj()

    @unittest.skipIf(
        not hasattr(multiprocessing, "get_context"), "No get_context method"
    )
    def test_ctx(self):
        pass


class GenAioRLockTest(BaseTest, _GenMixin):
    def setUp(self):
        super().setUp()
        self.Obj = aioprocessing.AioRLock
        self.inst = self.Obj()
        self.meth = "coro_acquire"


class GenAioConditionTest(BaseTest, _GenMixin):
    def setUp(self):
        super().setUp()
        self.Obj = aioprocessing.AioCondition
        self.inst = self.Obj()
        self.meth = "coro_acquire"


class GenAioSemaphoreTest(BaseTest, _GenMixin):
    def setUp(self):
        super().setUp()
        self.Obj = aioprocessing.AioSemaphore
        self.inst = self.Obj()
        self.meth = "coro_acquire"


class GenAioEventTest(BaseTest, _GenMixin):
    def setUp(self):
        super().setUp()
        self.Obj = aioprocessing.AioEvent
        self.inst = self.Obj()
        self.meth = "coro_wait"

    def _after(self):
        self.inst.set()


class GenAioBarrierTest(BaseTest, _GenMixin):
    def setUp(self):
        super().setUp()
        self.Obj = aioprocessing.AioBarrier
        self.inst = self.Obj(1)
        self.initargs = (1,)
        self.meth = "coro_wait"


class LoopLockTest(BaseTest):
    def setUp(self):
        pass

    def tearDown(self):
        pass

    def test_lock_with_loop(self):
        loop = asyncio.new_event_loop()
        lock = aioprocessing.AioLock()

        async def do_async_lock():
            await lock.coro_acquire(loop=loop)

        loop.run_until_complete(do_async_lock())
        loop.close()


class LockTest(BaseTest):
    def setUp(self):
        super().setUp()
        self.type_ = STANDARD_TYPE
        self.lock = aioprocessing.AioLock()

    def test_lock(self):
        self.assertEqual(True, self.lock.acquire())
        self.assertEqual(False, self.lock.acquire(False))
        self.assertEqual(None, self.lock.release())

    def test_lock_async(self):
        async def do_async_lock():
            self.assertEqual(True, (await self.lock.coro_acquire()))
            self.assertEqual(None, self.lock.release())

        self.loop.run_until_complete(do_async_lock())

    def test_lock_cm(self):
        event = Event()
        event2 = Event()
        q = Queue()

        async def with_lock():
            async with self.lock:
                event2.set()
                await asyncio.sleep(1)
                event.wait()

        p = Process(target=sync_lock, args=(self.lock, event, event2, q))
        p.start()
        self.loop.run_until_complete(with_lock())
        p.join()
        self.assertFalse(q.get())

    def test_lock_multiproc(self):
        e = Event()

        async def do_async_lock():
            self.assertEqual(False, (await self.lock.coro_acquire(False)))
            self.assertEqual(
                True, (await self.lock.coro_acquire(timeout=4))
            )

        p = Process(target=do_lock_acquire, args=(self.lock, e))
        p.start()
        e.wait()
        self.loop.run_until_complete(do_async_lock())


class LockManagerTest(LockTest):
    def setUp(self):
        super().setUp()
        self.type_ = MANAGER_TYPE
        self.manager = aioprocessing.AioManager()
        self.lock = self.manager.AioLock()

    def tearDown(self):
        super().tearDown()
        self.manager.shutdown()
        self.manager.join()


class RLockTest(LockTest):
    def setUp(self):
        super().setUp()
        self.lock = aioprocessing.AioRLock()

    def test_lock(self):
        self.assertEqual(True, self.lock.acquire())
        self.assertEqual(True, self.lock.acquire(False))
        self.assertEqual(None, self.lock.release())


class RLockManagerTest(RLockTest):
    def setUp(self):
        super().setUp()
        self.type_ = MANAGER_TYPE
        self.manager = aioprocessing.AioManager()
        self.lock = self.manager.AioRLock()

    def tearDown(self):
        super().tearDown()
        self.manager.shutdown()
        self.manager.join()


def mix_release(lock, q):
    try:
        try:
            lock.release()
        except (ValueError, AssertionError):
            pass
        else:
            q.put("Didn't get excepted AssertionError")
        lock.acquire()
        lock.release()
        q.put(True)
    except Exception:
        exc = traceback.format_exception(*sys.exc_info())
        q.put(exc)


class LockMixingTest(BaseTest):
    def setUp(self):
        super().setUp()
        self.lock = aioprocessing.AioRLock()

    def test_sync_lock(self):
        self.lock.acquire()
        self.lock.release()

    def test_mix_async_to_sync(self):
        async def do_acquire():
            await self.lock.coro_acquire()

        self.loop.run_until_complete(do_acquire())

        self.lock.release()

    def test_mix_with_procs(self):
        async def do_acquire():
            await self.lock.coro_acquire()

        q = Queue()
        p = Process(target=mix_release, args=(self.lock, q))
        self.loop.run_until_complete(do_acquire())
        p.start()
        self.lock.release()
        out = q.get(timeout=5)
        p.join()
        self.assertTrue(isinstance(out, bool))


class SpawnLockMixingTest(LockMixingTest):
    def setUp(self):
        super().setUp()
        context = get_context("spawn")
        self.lock = aioprocessing.AioLock(context=context)


if "forkserver" in get_all_start_methods():

    class ForkServerLockMixingTest(LockMixingTest):
        def setUp(self):
            super().setUp()
            context = get_context("forkserver")
            self.lock = aioprocessing.AioLock(context=context)


class SemaphoreTest(BaseTest):
    def setUp(self):
        super().setUp()
        self.sem = aioprocessing.AioSemaphore(2)

    def _test_semaphore(self, sem):
        self.assertReturnsIfImplemented(2, get_value, sem)
        self.assertEqual(True, sem.acquire())
        self.assertReturnsIfImplemented(1, get_value, sem)

        async def sem_acquire():
            self.assertEqual(True, (await sem.coro_acquire()))

        self.loop.run_until_complete(sem_acquire())
        self.assertReturnsIfImplemented(0, get_value, sem)
        self.assertEqual(False, sem.acquire(False))
        self.assertReturnsIfImplemented(0, get_value, sem)
        self.assertEqual(None, sem.release())
        self.assertReturnsIfImplemented(1, get_value, sem)
        self.assertEqual(None, sem.release())
        self.assertReturnsIfImplemented(2, get_value, sem)

    def test_semaphore(self):
        sem = self.sem
        self._test_semaphore(sem)
        self.assertEqual(None, sem.release())
        self.assertReturnsIfImplemented(3, get_value, sem)
        self.assertEqual(None, sem.release())
        self.assertReturnsIfImplemented(4, get_value, sem)


class BoundedSemaphoreTest(SemaphoreTest):
    def setUp(self):
        super().setUp()
        self.sem = aioprocessing.AioBoundedSemaphore(2)

    def test_semaphore(self):
        self._test_semaphore(self.sem)


def barrier_wait(barrier, event):
    event.set()
    barrier.wait()


class BarrierTest(BaseTest):
    def setUp(self):
        super().setUp()
        self.barrier = aioprocessing.AioBarrier(2)

    def _wait_barrier(self):
        self.barrier.wait()

    def test_barrier(self):
        fut = None

        async def wait_barrier_async():
            await self.barrier.coro_wait()

        async def wait_barrier():
            nonlocal fut
            fut = asyncio.ensure_future(wait_barrier_async())
            await asyncio.sleep(0.5)
            self.assertEqual(1, self.barrier.n_waiting)
            self.barrier.wait()

        # t = threading.Thread(target=self._wait_barrier)
        # t.start()
        self.loop.run_until_complete(wait_barrier())
        self.loop.run_until_complete(fut)

    def test_barrier_multiproc(self):
        event = Event()
        p = Process(target=barrier_wait, args=(self.barrier, event))
        p.start()

        async def wait_barrier():
            event.wait()
            await asyncio.sleep(0.2)
            self.assertEqual(1, self.barrier.n_waiting)
            await self.barrier.coro_wait()

        self.loop.run_until_complete(wait_barrier())
        p.join()


def set_event(event):
    event.set()


class EventTest(BaseTest):
    def setUp(self):
        super().setUp()
        self.event = aioprocessing.AioEvent()

    def test_event(self):
        p = Process(target=set_event, args=(self.event,))

        async def wait_event():
            await self.event.coro_wait()

        p.start()
        self.loop.run_until_complete(wait_event())
        p.join()


def cond_notify(cond, event):
    time.sleep(2)
    event.set()
    cond.acquire()
    cond.notify_all()
    cond.release()


class ConditionTest(BaseTest):
    def setUp(self):
        super().setUp()
        self.cond = aioprocessing.AioCondition()

    def test_cond(self):
        event = Event()

        def pred():
            return event.is_set()

        async def wait_for_pred():
            await self.cond.coro_acquire()
            await self.cond.coro_wait_for(pred)
            self.cond.release()

        p = Process(target=cond_notify, args=(self.cond, event))
        p.start()
        self.loop.run_until_complete(wait_for_pred())
        p.join()


if __name__ == "__main__":
    unittest.main()
