import platform
import subprocess
import sys

PYTEST_ARGS = ["-vv"] + dict(
    # measure coverage
    Linux=[
        "--cov",
        "simpy",
        "--cov-report",
        "term-missing:skip-covered",
        "--cov-fail-under",
        "92",
    ],
    # too slow for realtime tests
    Darwin=["-k", "not(test_rt)"],
    # test assumes POSIX paths... and is too slow
    Windows=["-k", "not(exception_chaining or test_rt)"],
)[platform.system()]

if __name__ == "__main__":
    print("Running pytest with", " ".join(PYTEST_ARGS))
    sys.exit(subprocess.call(["pytest", *PYTEST_ARGS], cwd="tests"))
