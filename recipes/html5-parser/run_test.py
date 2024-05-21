from subprocess import call
import sys
from pathlib import Path

WIN = sys.platform().startswith("win")

TESTS = Path("test").rglob("*.py")
PYTEST = ["pytest", "-vv", "--color=yes", "--tb=long", *TESTS]


def do(*args):
    args = list(map(str, args))
    print(">>>", *args, flush=True)
    rc = call(args)
    if rc:
        sys.exit(rc)
    return rc

if __name__ == "__main__":
    do("pip", "check")

    if WIN:
        sys.exit(do(*PYTEST))
    do("coverage", "run", "--source=html5_parser", "--branch", "-m", *PYTEST)
    do("coverage", "report", "--show-missing", "--skip-covered", "--fail-under=75")
