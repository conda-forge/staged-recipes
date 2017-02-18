import cymem
import pytest
import os

PACKAGE_DIR = os.path.abspath(os.path.dirname(cymem.__file__))
pytest.main([PACKAGE_DIR])
