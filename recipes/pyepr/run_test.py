#!/usr/bin/env python

import os
import sys
import shutil
import unittest

import epr

print('PyEPR: %s' % epr.__version__)
print('EPR API: %s' % epr.EPR_C_API_VERSION)
print('Python: %s' % sys.version)

sys.path.append('tests')

from test_all import *

try:
    unittest.main(verbosity=2)
finally:
    try:
        os.remove(os.path.join(TESTDIR, TEST_PRODUCT))
    except Exception:
        pass
