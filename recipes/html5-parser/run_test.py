from subprocess import call
import sys
from pathlib import Path


def do(*args):
    args = list(map(str, args))
    print(">>>", *args, flush=True)
    rc = call(args)
    if rc:
        sys.exit(rc)


do("pip", "check")

do(
    "coverage",
    "run",
    "--source=html5_parser",
    "--branch",
    "-m",
    "pytest",
    "-vv",
    "--color=yes",
    "--tb=long",
    *Path("tests").rglob("*.py"),
)

do("coverage", "report", "--show-missing", "--skip-covered", "--fail-under=75")
