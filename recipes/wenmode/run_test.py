import sys
from subprocess import call
import platform

COV_FAIL_UNDER = 96

PLATFORM = platform.system().lower()

PYTEST_SKIPS: list[str] = []


if PLATFORM == "windows":
    PYTEST_SKIPS += [
        "migration_python_code_blocks_are_discovered",
        "cli_reports_missing_input_file",
        "python_module_entrypoint_writes_utf8_stdout_on_non_utf8_locale",
    ]
elif PLATFORM == "darwin":
    PYTEST_SKIPS += [
        "cf-not-a-test",
        "scale_nearly_linearly",
    ]

PYTEST_ARGS = [
    "-vv",
    "--tb=long",
    "--color=yes",
    *([] if not PYTEST_SKIPS else ["-k", f"""not ({" or ".join(PYTEST_SKIPS)})"""]),
]

COV_RUN = ["coverage", "run", "--source=wenmode", "--branch", "--append"]
CMDS = [
    [*COV_RUN, "-m", "wenmode", "--version"],
    [*COV_RUN, "-m", "wenmode", "--help"],
    [*COV_RUN, "-m", "pytest", *PYTEST_ARGS],
    ["mypy", "-p", "wenmode"],
]

if PLATFORM == "linux":
    CMDS += [
        [
            "coverage",
            "report",
            "--show-missing",
            "--skip-covered",
            f"--fail-under={COV_FAIL_UNDER}",
        ]
    ]

if __name__ == "__main__":
    sys.exit(any(call(cmd) for cmd in CMDS))
