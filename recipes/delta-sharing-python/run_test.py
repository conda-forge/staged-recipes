import subprocess
from pathlib import Path
import sys
import platform

TESTS = Path(__file__).parent / "src/python/delta_sharing"

WIN = platform.system() == "Windows"

if WIN:
    COV_THRESHOLD = 50
else:
    COV_THRESHOLD = 68

for tst in TESTS.rglob("*.py"):
    tst.write_text(tst.read_text().replace("delta_sharing.tests.", "."))

PYTEST_ARGS = [
    "pytest",
    "-vv",
    "--cov=delta_sharing",
    "--no-cov-on-fail",
    "--cov-report=term-missing:skip-covered",
    f"--cov-fail-under={COV_THRESHOLD}",
]

if WIN:
    """
    >               raise ValueError("Protocol not known: %s" % protocol)
    E               ValueError: Protocol not known: c

    ..\..\..\..\_test_env\lib\site-packages\fsspec\registry.py:216: ValueError
    =========================== short test summary info ===========================
    FAILED tests/test_reader.py::test_to_pandas_non_partitioned - ValueError: Pro...
    FAILED tests/test_reader.py::test_to_pandas_partitioned - ValueError: Protoco...
    FAILED tests/test_reader.py::test_to_pandas_partitioned_different_schemas - V...
    """
    PYTEST_ARGS += ["-k", "not (pandas_non_partitioned or pandas_partitioned)"]

sys.exit(subprocess.call(PYTEST_ARGS, cwd=str(TESTS)))
