import subprocess
from pathlib import Path
import sys

TESTS = Path(__file__).parent / "src/python/delta_sharing"

COV_THRESHOLD = 68

for tst in TESTS.rglob("*.py"):
    tst.write_text(tst.read_text().replace("delta_sharing.tests.", "."))

sys.exit(
    subprocess.call(
        [
            "pytest",
            "-vv",
            "--cov=delta_sharing",
            "--no-cov-on-fail",
            "--cov-report=term-missing:skip-covered",
            f"--cov-fail-under={COV_THRESHOLD}",
        ],
        cwd=str(TESTS),
    )
)
