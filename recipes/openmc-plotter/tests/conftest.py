import os
from pathlib import Path

import pytest

@pytest.fixture(scope='module', autouse=True)
def setup_regression_test(request):
    # Change to test directory
    olddir = request.fspath.dirpath().chdir()
    try:
        yield
    finally:
        # some cleanup
        plot_settings = Path('plot_settings.pkl')
        if plot_settings.exists():
            plot_settings.unlink()

        olddir.chdir()
