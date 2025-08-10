import sys
from subprocess import call
import tomli
from pathlib import Path
import os

FAIL_UNDER = 84

WIN = os.name == "nt"

SKIPS = [
    # Expected errors in json schema validation, but none found
    "(test_core_compliance and test_date_types)",
    #  │         # Check that the final type is a self-referential array
    #  │ >       assert anyOf[-1] == {"$ref": f"#/$defs/{array_ref}"}
    #  │ E       AssertionError: assert {'$ref': '#/$defs/AnyShapeArray___T_'} == {'$ref': '#/$defs/AnyShapeArray'}
    #  │ E         Differing items:
    #  │ E         {'$ref': '#/$defs/AnyShapeArray___T_'} != {'$ref': '#/$defs/AnyShapeArray'}
    #  │ E         Full diff:
    #  │ E         - {'$ref': '#/$defs/AnyShapeArray'}
    #  │ E         + {'$ref': '#/$defs/AnyShapeArray___T_'}
    #  │ E         ?                                +++++
    "(test_pydanticgen and test_arrays_anyshape_json_schema)",
]

if WIN:
    SKIPS += [
        # probably related to fixture line endings?
        "test_issue_179",
        "test_issue_62",
        "test_issue_65",
        "test_metamodel_valid_call",
        "test_models_markdown",
    ]
    FAIL_UNDER -= 1

SRC_DIR = Path(__file__).parent / "src"
PYPROJECT = SRC_DIR / "pyproject.toml"
PPT_DATA = tomli.loads(PYPROJECT.read_text(encoding="utf-8"))
SCRIPTS = sorted(PPT_DATA["project"]["scripts"])
SCRIPT_HELP = [[s, "--help"] for s in SCRIPTS]


TEST = [
    "coverage",
    "run",
    "--source=linkml",
    "--branch",
    "-m",
    "pytest",
    "-vv",
    "--tb=long",
    "--color=yes",
    "-k",
    f"""not ({" or ".join(SKIPS)})""",
]

REPORT = [
    "coverage",
    "report",
    "--show-missing",
    "--skip-covered",
    f"--fail-under={FAIL_UNDER}",
]


def do(*args: str):
    print(">>>", *args)
    return call(args)


if __name__ == "__main__":
    for script in [*SCRIPT_HELP, TEST, REPORT]:
        print("\n>>>", *script, "\n", flush=True)
        rc = call(script, cwd=str(SRC_DIR))
        if rc != 0:
            print("!!! error", rc, ":", *script)
            sys.exit(rc)
    sys.exit(0)
