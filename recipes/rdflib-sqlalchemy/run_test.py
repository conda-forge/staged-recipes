import subprocess
import os
import sys

ENV = dict(**os.environ)
ENV.update(DB="sqlite", DBURI="sqlite://")
COV_THRESHOLD = 77

PYTEST_ARGS = [
    "pytest",
    "test",
    "-vv",
    "--cov=rdflib_sqlalchemy",
    "--cov-report=term-missing:skip-covered",
    f"--cov-fail-under={COV_THRESHOLD}",
    "--no-cov-on-fail"
]

if __name__ == "__main__":
    sys.exit(subprocess.call(PYTEST_ARGS, env=ENV))
