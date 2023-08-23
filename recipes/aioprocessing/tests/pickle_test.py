import pickle
import unittest

from aioprocessing.executor import _ExecutorMixin


class PickleTest(unittest.TestCase):
    def test_pickle_queue(self):
        q = _ExecutorMixin()
        q.test = "abc"
        pickled = pickle.dumps(q)
        unpickled = pickle.loads(pickled)
        self.assertEqual(q.test, unpickled.test)


if __name__ == "__main__":
    unittest.main()
