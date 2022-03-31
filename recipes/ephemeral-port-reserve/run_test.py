import platform
import subprocess
import sys

PLATFORM = platform.system()
WIN = PLATFORM == "Windows"
OSX = PLATFORM == "Darwin"

PYTEST_ARGS = [
    "-vv",
    "--cov=ephemeral_port_reserve",
    "--cov-report=term-missing:skip-covered",
    "--no-cov-on-fail"
]

if OSX:
    PYTEST_ARGS += ["-k", "not fqdn"]
elif WIN:
    PYTEST_ARGS += ["-k", "not (fqdn or port_in_use or localhost)"]
else:
    PYTEST_ARGS += ["--cov-fail-under", "92"]

if __name__ == "__main__":
    sys.exit(subprocess.call(["pytest", *PYTEST_ARGS], cwd="src/tests"))
