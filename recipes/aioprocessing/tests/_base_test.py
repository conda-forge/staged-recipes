import asyncio
import unittest
import inspect

import aioprocessing.mp as multiprocessing


class BaseTest(unittest.TestCase):
    def setUp(self):
        self.loop = asyncio.new_event_loop()

    def tearDown(self):
        self.loop.close()

    def assertReturnsIfImplemented(self, value, func, *args):
        try:
            res = func(*args)
        except NotImplementedError:
            pass
        else:
            return self.assertEqual(value, res)


class _GenMixin:
    initargs = ()
    args = ()

    def test_loop(self):
        loop = asyncio.new_event_loop()
        val = getattr(self.inst, self.meth)(*self.args, loop=loop)
        self._after()
        if inspect.isawaitable(val):
            loop.run_until_complete(val)
        loop.close()

    @unittest.skipIf(
        not hasattr(multiprocessing, "get_context"),
        "Not supported in this version of Python",
    )
    def test_ctx(self):
        ctx = multiprocessing.get_context("spawn")
        a = self.Obj(*self.initargs, context=ctx)
        if hasattr(a, "close"):
            a.close()

    def _after(self):
        pass
