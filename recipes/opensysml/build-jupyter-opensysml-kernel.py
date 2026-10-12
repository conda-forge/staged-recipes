import subprocess
import sys
import os
from pathlib import Path

SRC_DIR = Path(os.environ["SRC_DIR"])
GO_MOD = os.environ["GO_MOD"]
PIP_INSTALL = os.environ["PIP_INSTALL"]

JS_EXT_DIR = SRC_DIR / GO_MOD / "editors/jupyterlab"
PY_JP_DIR = SRC_DIR / GO_MOD / "client/jupyter-kernel"


def do(cwd: Path, cmd: str) -> int:
    """Echo and call with shell expansion."""
    print("\n>>>", cwd, "\n\t", cmd, flush=True)
    rc = subprocess.call(cmd, shell=True, cwd=str(cwd))
    print("rc", rc, cmd, "\n", flush=True)
    return rc


def main() -> int:
    do(JS_EXT_DIR, """npm install --ignore-scripts""")
    do(JS_EXT_DIR, """npm run build:lib""")
    do(JS_EXT_DIR, """jupyter-builder build .""")
    do(PY_JP_DIR, f"""{sys.executable} -m {PIP_INSTALL}""")
    return 0


if __name__ == "__main__":
    sys.exit(main())
