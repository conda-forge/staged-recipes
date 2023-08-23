import unittest
from array import array

import aioprocessing
import aioprocessing.mp as multiprocessing
from aioprocessing.connection import AioConnection, AioListener, AioClient
from aioprocessing.mp import Process

from ._base_test import BaseTest


def conn_send(conn, val):
    conn.send(val)


def client_sendback(event, address, authkey):
    event.wait()
    conn = multiprocessing.connection.Client(address, authkey=authkey)
    got = conn.recv()
    conn.send(got + got)
    conn.close()


def listener_sendback(event, address, authkey):
    listener = multiprocessing.connection.Listener(address, authkey=authkey)
    event.set()
    conn = listener.accept()
    inval = conn.recv()
    conn.send_bytes(array("i", [inval, inval + 1, inval + 2, inval + 3]))
    conn.close()
    listener.close()


class PipeTest(BaseTest):
    def test_pipe(self):
        conn1, conn2 = aioprocessing.AioPipe()
        val = 25
        p = Process(target=conn_send, args=(conn1, val))
        p.start()

        async def conn_recv():
            out = await conn2.coro_recv()
            self.assertEqual(out, val)

        self.loop.run_until_complete(conn_recv())


class ListenerTest(BaseTest):
    def test_listener(self):
        address = ("localhost", 8999)
        authkey = b"abcdefg"
        event = multiprocessing.Event()
        p = Process(target=client_sendback, args=(event, address, authkey))
        p.start()
        listener = AioListener(address, authkey=authkey)
        try:
            event.set()
            conn = listener.accept()
            self.assertIsInstance(conn, AioConnection)
            conn.send("")
            conn.close()
            event.clear()
            p.join()
            p = Process(target=client_sendback, args=(event, address, authkey))
            p.start()

            def conn_accept():
                fut = listener.coro_accept()
                event.set()
                conn = yield from fut
                self.assertIsInstance(conn, AioConnection)
                yield from conn.coro_send("hi there")
                back = yield from conn.coro_recv()
                self.assertEqual(back, "hi therehi there")
                conn.close()

            self.loop.run_until_complete(conn_accept())
            p.join()
        finally:
            listener.close()

    def test_client(self):
        address = ("localhost", 8999)
        authkey = b"abcdefg"
        event = multiprocessing.Event()
        p = Process(target=listener_sendback, args=(event, address, authkey))
        p.start()
        event.wait()
        conn = AioClient(address, authkey=authkey)
        self.assertIsInstance(conn, AioConnection)

        def do_work():
            yield from conn.coro_send(25)
            arr = array("i", [0, 0, 0, 0])
            yield from conn.coro_recv_bytes_into(arr)
            self.assertEqual(arr, array("i", [25, 26, 27, 28]))
            conn.close()

        self.loop.run_until_complete(do_work())
        p.join()

    def test_listener_ctxmgr(self):
        address = ("localhost", 8999)
        authkey = b"abcdefg"
        with AioListener(address, authkey=authkey) as listener:
            self.assertIsInstance(listener, AioListener)
        self.assertRaises(OSError, listener.accept)

    def test_client_ctxmgr(self):
        address = ("localhost", 8999)
        authkey = b"abcdefg"
        event = multiprocessing.Event()
        p = Process(target=listener_sendback, args=(event, address, authkey))
        p.daemon = True
        p.start()
        event.wait()
        with AioClient(address, authkey=authkey) as conn:
            self.assertIsInstance(conn, AioConnection)
        self.assertRaises(OSError, conn.send, "hi")
        p.terminate()
        p.join()


if __name__ == "__main__":
    unittest.main()
