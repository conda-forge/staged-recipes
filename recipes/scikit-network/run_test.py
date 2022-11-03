import os, pathlib, subprocess, sys

SRC_DIR = pathlib.Path(os.environ["SRC_DIR"])
TEST_DIRS = (SRC_DIR / "sknetwork").glob("*/tests")
PYTEST_ARGS = ["pytest", "-vv", "-k", "not gnn_classifier_early_stopping"]

failed = []

for test_dir in TEST_DIRS:
    if subprocess.call(PYTEST_ARGS, cwd=str(test_dir)):
        failed += [test_dir.parent.name]

if failed:
    print("Failed tests in:", sorted(failed))

sys.exit(len(failed))
