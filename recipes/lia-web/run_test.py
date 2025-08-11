import sys
import os
from subprocess import call
from pathlib import Path

PYPROJECT = Path("pyproject.toml")

FAIL_UNDER = 100

SKIPS = [
    # remove when/if we have multiple hard skips for `-k` syntax
    "not-a-test",
    # not sure
    "test_quart_adapter",
]

if os.name == "nt":
    SKIPS += [
        # chalice not available for windows
        "chalice"
    ]

UTF8 = {"encoding": "utf-8"}
TEST = [
    "pytest",
    "-vv",
    "--tb=long",
    "--color=yes",
    "-k",
    f"""not ({" or ".join(SKIPS)})""",
]


def do(args: list[str]) -> int:
    print(">>>", *args)
    return call(args)


if __name__ == "__main__":
    sys.exit(do(TEST))
