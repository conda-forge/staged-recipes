import os
import sys

import fbprophet
import pytest


PACKAGE_DIR = os.path.dirname(os.path.abspath(fbprophet.__file__))

sys.exit(pytest.main(['-v', PACKAGE_DIR]))
