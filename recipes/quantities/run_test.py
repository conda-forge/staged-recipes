import os
import sys


if sys.version.startswith('2.6') or sys.version.startswith('3.1'):
    import unittest2 as unittest
else:
    import unittest

suite = unittest.TestLoader().discover('quantities')
unittest.TextTestRunner(verbosity=1).run(suite)
