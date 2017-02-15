import os
import pytest
import thinc

PACKAGE_DIR = os.path.abspath(os.path.dirname(thinc.__file__))
pytest.main([PACKAGE_DIR])
