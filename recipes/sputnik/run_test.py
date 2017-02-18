import os
import pytest
import sputnik

PACKAGE_DIR = os.path.abspath(os.path.dirname(sputnik.__file__))
pytest.main([PACKAGE_DIR])
