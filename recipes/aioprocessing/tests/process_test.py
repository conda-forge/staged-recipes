import unittest
import aioprocessing.mp as multiprocessing

import aioprocessing
from ._base_test import BaseTest, _GenMixin


def f(q, a, b):
    q.put((a, b))


def dummy():
    pass


class GenAioProcessTest(BaseTest, _GenMixin):
    def setUp(self):
        super().setUp()
        self.Obj = aioprocessing.AioProcess
        self.inst = self.Obj(target=dummy)
        self.inst.start()
        self.meth = "coro_join"


class ProcessTest(BaseTest):
    def test_pickle_queue(self):
        t = ("a", "b")
        q = multiprocessing.Queue()
        p = aioprocessing.AioProcess(target=f, args=(q,) + t)
        p.start()

        async def join():
            await p.coro_join()

        self.loop.run_until_complete(join())
        self.assertEqual(q.get(), t)


if __name__ == "__main__":
    unittest.main()
