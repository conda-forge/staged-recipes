# from https://github.com/teepark/python-lzf/releases/tag/release-0.2.6
import os
import unittest

import lzf


class LZFTest(object):
    def __init__(self, *args, **kwargs):
        super(LZFTest, self).__init__(*args, **kwargs)
        self.VAL = self.VAL.encode('utf8')

    def compress(self, text):
        # lzf guarantees that even if the compressed version is longer, it is
        # within 104% of the original size (rounded up), so this should work
        return lzf.compress(text, len(text) * 2)

    def test_selective(self):
        compressed = self.compress(self.VAL)
        self.assertEqual(lzf.decompress(compressed, len(self.VAL) - 1), None)
        assert lzf.decompress(compressed, len(self.VAL))

    def test_decompresses_correctly(self):
        compressed = self.compress(self.VAL)
        self.assertEqual(lzf.decompress(compressed, len(self.VAL)), self.VAL)

    def test_compression_negative_maxlen(self):
        self.assertRaises(ValueError, lzf.compress, self.VAL, -6)

    def test_decompression_negative_maxlen(self):
        c = self.compress(self.VAL)
        self.assertRaises(ValueError, lzf.decompress, c, -1)

    def test_wrong_maxlen_type(self):
        self.assertRaises(TypeError, lzf.compress, self.VAL, "hi there")


class ShortString(LZFTest, unittest.TestCase):
    VAL = "this is a test"

class StringWithRepetition(LZFTest, unittest.TestCase):
    VAL = "a longer string, repeating. " * 500

class LongStringNoRepetition(LZFTest, unittest.TestCase):
    VAL = open(os.path.join(os.path.dirname(__file__), "lzf_module.c")).read()


if __name__ == '__main__':
    unittest.main()
