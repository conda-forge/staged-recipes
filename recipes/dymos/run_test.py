import os
import subprocess
import sys
from os.path import join, dirname

import dymos

# don't test the code_review stuff
TESTFLO = """[testflo]
numprocs = 2
skip_dirs =
  code_review

"""

with open(".testflo", "w") as fp:
    fp.write(TESTFLO)

test_files_to_delete = [
    # # can't test these, yet, because of playwright
    # ["visualization", "n2_viewer", "tests", "test_gui.py"],
    # ["docs", "openmdao_book", "tests", "test_jupyter_gui_test.py"],
    # # some new issue as of 3.4.1
    # ["core", "tests", "test_feature_cache_linear_solution.py"]
]

[
    os.unlink(join(dirname(dymos.__file__), *tf2d))
    for tf2d in test_files_to_delete
]

sys.exit(subprocess.call([
    "testflo", "--config", ".testflo", "--numprocs", "1", "dymos", "-v", "--pre_announce"
]))
