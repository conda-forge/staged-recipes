import os
import pytest

# workaround to undo conda-forge settng CI env var
os.environ['CI'] = 'true'
test_prefix = os.environ['PREFIX']

pytest.main(['-v', os.path.join(test_prefix, 'tests')])