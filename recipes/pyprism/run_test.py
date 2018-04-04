import os
testdir = os.path.join('tests')
os.chdir(testdir)

import pytest
import pyPRISM
pytest.main(['-x','.'])
