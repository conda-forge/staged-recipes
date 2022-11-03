import os, pathlib, subprocess, sys

SRC_DIR = pathlib.Path(os.environ["SRC_DIR"])
TEST_DIRS = (SRC_DIR / "sknetwork").glob("*/tests")

failed = []

for test_dir in TEST_DIRS:
    if subprocess.call(["pytest", "-vv"], cwd=str(test_dir)):
        failed += [test_dir.name]

if failed:
    print("Failed tests in:", sorted(failed))

sys.exit(len(failed))
