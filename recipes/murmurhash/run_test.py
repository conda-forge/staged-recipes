import murmurhash
import os
import pytest

PACKAGE_DIR = os.path.abspath(os.path.dirname(murmurhash.__file__))
pytest.main([PACKAGE_DIR])
