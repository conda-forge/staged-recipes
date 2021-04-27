""" test a jupyter-starter
"""
from pathlib import Path
import pytest
import subprocess
import sys
import os
import json

# TODO: parametrize most of the inputs

PREFIX = Path(os.environ["PREFIX"])
PKG_NAME = os.environ["PKG_NAME"]
ROOT = PREFIX / f"share/jupyter/starters/{PKG_NAME}"
ETC = PREFIX / "etc/jupyter"
APPS = ["notebook", "server"]

# the solutions sometimes invoke big tensorflow calls
SKIP = ["Solution"]

NOTEBOOKS = sorted(
    [p for p in ROOT.rglob("*.ipynb") if not any(s in p.name for s in SKIP)]
)

# really just looking for broken imports
DISALLOWED_ERRORS = ["ModuleNotFoundError"]


@pytest.mark.parametrize("notebook,path", [[p.name, p] for p in NOTEBOOKS])
def test_nbconvert(notebook, path, capsys):
    print(str(path.relative_to(ROOT)))
    print("=" * 80)
    subprocess.call(
        [
            "jupyter",
            "nbconvert",
            "--execute",
            str(path),
            "--to",
            "html",
            "--ExecutePreprocessor.timeout=5",
        ]
    )
    captured = capsys.readouterr()
    print("=" * 80)
    print(captured.out)
    print("=" * 80)
    print(captured.err)
    for err in DISALLOWED_ERRORS:
        assert err not in captured.out, captured.out
        assert err not in captured.err, captured.err


@pytest.mark.parametrize("app", APPS)
def test_jupyter_config(app):
    conf_file = ETC / f"jupyter_{app}_config.d/{PKG_NAME}.json"
    conf = json.loads(conf_file.read_text())
    print(conf)
    for key, starter in conf["StarterManager"]["extra_starters"].items():
        src = starter["src"]
        assert Path(src).exists()
        assert src.startswith(str(PREFIX))


if __name__ == "__main__":
    sys.exit(pytest.main([__file__, "-svv"]))
