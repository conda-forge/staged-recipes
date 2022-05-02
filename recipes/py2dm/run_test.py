#!/usr/bin/env python3

import unittest

class Py2DMTestCase(unittest.TestCase):
    # The module will throw a warning if the C implementation cannot be
    # loaded. Make sure this warning is NOT thrown
    @unittest.expectedFailure
    def test_cimport(self):
        with self.assertWarns(UserWarning):
            import py2dm

if __name__ == '__main__':
    unittest.main()
