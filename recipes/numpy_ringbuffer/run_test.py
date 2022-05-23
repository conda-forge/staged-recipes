import unittest
import numpy as np
from numpy_ringbuffer import RingBuffer

class TestAll(unittest.TestCase):
	def test_dtype(self):
		r = RingBuffer(5)
		self.assertEqual(r.dtype, np.dtype(np.float64))

		r = RingBuffer(5, dtype=np.bool)
		self.assertEqual(r.dtype, np.dtype(np.bool))

	def test_sizes(self):
		r = RingBuffer(5, dtype=(int, 2))
		self.assertEqual(r.maxlen, 5)
		self.assertEqual(len(r), 0)
		self.assertEqual(r.shape, (0,2))

		r.append([0, 0])
		self.assertEqual(r.maxlen, 5)
		self.assertEqual(len(r), 1)
		self.assertEqual(r.shape, (1,2))

	def test_append(self):
		r = RingBuffer(5)

		r.append(1)
		np.testing.assert_equal(r, np.array([1]))
		self.assertEqual(len(r), 1)

		r.append(2)
		np.testing.assert_equal(r, np.array([1, 2]))
		self.assertEqual(len(r), 2)

		r.append(3)
		r.append(4)
		r.append(5)
		np.testing.assert_equal(r, np.array([1, 2, 3, 4, 5]))
		self.assertEqual(len(r), 5)

		r.append(6)
		np.testing.assert_equal(r, np.array([2, 3, 4, 5, 6]))
		self.assertEqual(len(r), 5)

		self.assertEqual(r[4], 6)
		self.assertEqual(r[-1], 6)

	def test_getitem(self):
		r = RingBuffer(5)
		r.extend([1, 2, 3])
		r.extendleft([4, 5])
		expected = np.array([4, 5, 1, 2, 3])
		np.testing.assert_equal(r, expected)

		for i in range(r.maxlen):
			self.assertEqual(expected[i], r[i])

		ii = [0, 4, 3, 1, 2]
		np.testing.assert_equal(r[ii], expected[ii])

	def test_appendleft(self):
		r = RingBuffer(5)

		r.appendleft(1)
		np.testing.assert_equal(r, np.array([1]))
		self.assertEqual(len(r), 1)

		r.appendleft(2)
		np.testing.assert_equal(r, np.array([2, 1]))
		self.assertEqual(len(r), 2)

		r.appendleft(3)
		r.appendleft(4)
		r.appendleft(5)
		np.testing.assert_equal(r, np.array([5, 4, 3, 2, 1]))
		self.assertEqual(len(r), 5)

		r.appendleft(6)
		np.testing.assert_equal(r, np.array([6, 5, 4, 3, 2]))
		self.assertEqual(len(r), 5)

	def test_extend(self):
		r = RingBuffer(5)
		r.extend([1, 2, 3])
		np.testing.assert_equal(r, np.array([1, 2, 3]))
		r.popleft()
		r.extend([4, 5, 6])
		np.testing.assert_equal(r, np.array([2, 3, 4, 5, 6]))
		r.extendleft([0, 1])
		np.testing.assert_equal(r, np.array([0, 1, 2, 3, 4]))

		r.extendleft([1, 2, 3, 4, 5, 6, 7])
		np.testing.assert_equal(r, np.array([1, 2, 3, 4, 5]))

		r.extend([1, 2, 3, 4, 5, 6, 7])
		np.testing.assert_equal(r, np.array([3, 4, 5, 6, 7]))

	def test_pops(self):
		r = RingBuffer(3)
		r.append(1)
		r.appendleft(2)
		r.append(3)
		np.testing.assert_equal(r, np.array([2, 1, 3]))

		self.assertEqual(r.pop(), 3)
		np.testing.assert_equal(r, np.array([2, 1]))

		self.assertEqual(r.popleft(), 2)
		np.testing.assert_equal(r, np.array([1]))

		# test empty pops
		empty = RingBuffer(1)
		with self.assertRaisesRegex(IndexError, "pop from an empty RingBuffer"):
			empty.pop()
		with self.assertRaisesRegex(IndexError, "pop from an empty RingBuffer"):
			empty.popleft()

	def test_2d(self):
		r = RingBuffer(5, dtype=(np.float, 2))

		r.append([1, 2])
		np.testing.assert_equal(r, np.array([[1, 2]]))
		self.assertEqual(len(r), 1)
		self.assertEqual(np.shape(r), (1, 2))

		r.append([3, 4])
		np.testing.assert_equal(r, np.array([[1, 2], [3, 4]]))
		self.assertEqual(len(r), 2)
		self.assertEqual(np.shape(r), (2, 2))

		r.appendleft([5, 6])
		np.testing.assert_equal(r, np.array([[5, 6], [1, 2], [3, 4]]))
		self.assertEqual(len(r), 3)
		self.assertEqual(np.shape(r), (3, 2))

		np.testing.assert_equal(r[0], [5, 6])
		np.testing.assert_equal(r[0,:], [5, 6])
		np.testing.assert_equal(r[:,0], [5, 1, 3])

	def test_iter(self):
		r = RingBuffer(5)
		for i in range(5):
			r.append(i)
		for i, j in zip(r, range(5)):
			self.assertEqual(i, j)

	def test_repr(self):
		r = RingBuffer(5, dtype=np.int)
		for i in range(5):
			r.append(i)

		self.assertEqual(repr(r), '<RingBuffer of array([0, 1, 2, 3, 4])>')

	def test_no_overwrite(self):
		r = RingBuffer(3, allow_overwrite=False)
		r.append(1)
		r.append(2)
		r.appendleft(3)
		with self.assertRaisesRegex(IndexError, 'overwrite'):
			r.appendleft(4)
		with self.assertRaisesRegex(IndexError, 'overwrite'):
			r.extendleft([4])
		r.extendleft([])

		np.testing.assert_equal(r, np.array([3, 1, 2]))
		with self.assertRaisesRegex(IndexError, 'overwrite'):
			r.append(4)
		with self.assertRaisesRegex(IndexError, 'overwrite'):
			r.extend([4])
		r.extend([])

		# works fine if we pop the surplus
		r.pop()
		r.append(4)
		np.testing.assert_equal(r, np.array([3, 1, 4]))

	def test_degenerate(self):
		r = RingBuffer(0)
		np.testing.assert_equal(r, np.array([]))

		# this does not error with deque(maxlen=0), so should not error here
		try:
			r.append(0)
			r.appendleft(0)
		except IndexError:
			self.fail()

if not hasattr(TestAll, 'assertRaisesRegex'):
	TestAll.assertRaisesRegex = TestAll.assertRaisesRegexp

if __name__ == '__main__':
	unittest.main()
