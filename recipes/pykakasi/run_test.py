# the upstream session-scoped test fixture redundantly re-generates
# the dictionaries that are already packaged, see
# https://github.com/miurahr/pykakasi/blob/v2.0.4/tests/conftest.py
# unless we specify the following environment variable:
import os
os.environ["TOX_ENV_DIR"] = "dummy"

import pytest
pytest.main(["tests/"])
