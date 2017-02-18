import os
import preshed
import pytest

PACKAGE_DIR = os.path.abspath(os.path.dirname(preshed.__file__))
pytest.main([PACKAGE_DIR])
