import unittest
from concurrent.futures import ProcessPoolExecutor

import aioprocessing
from aioprocessing.mp import Process, Event, util
from ._base_test import BaseTest, _GenMixin


def queue_put(q, val):
    val = q.put(val)
    return val


def queue_get(q, e):
    val = q.get()
    e.set()
    q.put(val)


class GenQueueMixin(_GenMixin):
    def setUp(self):
        super().setUp()
        self.inst = self.Obj()
        self.meth = "coro_get"

    def _after(self):
        self.inst.put(1)


class GenAioQueueTest(GenQueueMixin, BaseTest):
    def setUp(self):
        self.Obj = aioprocessing.AioQueue
        super().setUp()


class GenAioSimpleQueueTest(GenQueueMixin, BaseTest):
    def setUp(self):
        self.Obj = aioprocessing.AioSimpleQueue
        super().setUp()


class GenAioJoinableQueueTest(GenQueueMixin, BaseTest):
    def setUp(self):
        self.Obj = aioprocessing.AioJoinableQueue
        super().setUp()


class QueueTest(BaseTest):
    def test_blocking_put(self):
        q = aioprocessing.AioQueue()

        async def queue_put():
            await q.coro_put(1)

        self.loop.run_until_complete(queue_put())
        self.assertEqual(q.get(), 1)

    def test_put_get(self):
        q = aioprocessing.AioQueue()
        val = 1
        p = Process(target=queue_put, args=(q, val))

        async def queue_get():
            ret = await q.coro_get()
            self.assertEqual(ret, val)

        p.start()
        self.loop.run_until_complete(queue_get())
        p.join()

    def test_get_put(self):
        q = aioprocessing.AioQueue()
        e = Event()
        val = 2

        async def queue_put():
            await q.coro_put(val)

        p = Process(target=queue_get, args=(q, e))
        p.start()
        self.loop.run_until_complete(queue_put())
        e.wait()
        out = q.get()
        p.join()
        self.assertEqual(out, val)

    def test_simple_queue(self):
        q = aioprocessing.AioSimpleQueue()
        val = 8

        async def queue_put():
            await q.coro_put(val)

        self.loop.run_until_complete(queue_put())
        out = q.get()
        self.assertEqual(val, out)


class ManagerQueueTest(BaseTest):
    @unittest.skipIf(
        "multiprocess.util" in str(util),
        "concurrent.futures is not yet supported by uqfoundation "
        "(https://github.com/uqfoundation/pathos/issues/90)"
    )
    def test_executor(self):
        m = aioprocessing.AioManager()
        q = m.AioQueue()
        p = ProcessPoolExecutor(max_workers=1)
        val = 4

        def submit():
            yield p.submit(queue_put, q, val)

        next(submit())

        async def queue_get():
            out = await q.coro_get()
            self.assertEqual(out, val)
            await q.coro_put(5)

        self.loop.run_until_complete(queue_get())
        returned = q.get()
        self.assertEqual(returned, 5)
        p.shutdown()


class JoinableQueueTest(BaseTest):
    def test_join_empty_queue(self):
        q = aioprocessing.AioJoinableQueue()

        async def join():
            await q.coro_join()

        self.loop.run_until_complete(join())


if __name__ == "__main__":
    unittest.main()
