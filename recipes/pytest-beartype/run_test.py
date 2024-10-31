from sys import exit
from subprocess import call

REPORT = [
    "coverage",
    "report",
    "--show-missing",
    "--skip-covered",
    "--fail-under",
    "98",
]
PYTEST = ["pytest", "-vv", "--tb=long", "--color=yes"]
RUN = ["coverage", "run", "--append", "--branch", "--source=pytest_beartype", "-m"]
EXCURSIONS = [
    [],
    ["--beartype-packages", "pytest_beartype"],
    ["--beartype-packages", "pytest"],
    ["--beartype-packages", "*"],
]
CMDS = [*[[*RUN, *PYTEST, *ex] for ex in EXCURSIONS], REPORT]

if __name__ == "__main__":
    exit(max([[print("\n", *cmd, flush=True), call(cmd)][1] for cmd in CMDS]))
