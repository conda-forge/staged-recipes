import os
import shutil
import site
import sys
import tarfile


from pathlib import Path
from subprocess import call
from tempfile import TemporaryDirectory
from urllib.request import urlretrieve

COV_FAIL_UNDER = 78

PKG_VERSION = os.environ["PKG_VERSION"]
HERE = Path(__file__).parent
SP_DIR = Path(site.getsitepackages()[-1])

TARBALL = f"v{PKG_VERSION}.tar.gz"
URL = f"https://github.com/multi-objective/moocore/archive/refs/tags/{TARBALL}"


PYTEST = [
    "pytest",
    "-vv",
    "--tb=long",
    "--color=yes",
    "-c",
    "pyproject.toml",
    "--doctest-continue-on-failure",
    "--import-mode=importlib",
    "--ignore",
    str(SP_DIR / "moocore/_ffi_build.py"),
    "--doctest-modules",
    str(SP_DIR / "moocore"),
    "tests",
]
TEST = ["coverage", "run", "--source=moocore", "--branch", "--append", "-m", *PYTEST]

COV_CMDS = [
    TEST,
    [
        "coverage",
        "report",
        "--show-missing",
        "--skip-covered",
        f"--fail-under={COV_FAIL_UNDER}",
    ],
]


def setup_test_cwd(td: str, conf_py: Path) -> Path:
    """Re-download the sdist because the test fixtures are big, fix some paths."""
    tdp = Path(td)
    cwd = tdp / f"moocore-{PKG_VERSION}/python"
    ttf = tdp / TARBALL

    urlretrieve(URL, ttf)

    with tarfile.open(ttf, "r:gz") as tfh:
        tfh.extractall(td)

    shutil.copy2(Path(cwd / "src/conftest.py"), conf_py)
    return cwd


def do(args: list[any], cwd: Path) -> int:
    """Noisily run a subprocess."""
    str_args = [*map(str, args)]
    print(">>>", " \\\n\t".join(str_args))
    rc = call(str_args, cwd=str(cwd))
    print(f"... rc: {rc} from:", *str_args, flush=True)
    return rc


def main() -> int:
    """Run tests under ``coverage`` with a number of path/config hacks."""
    # avoid upstream's `conftest.py` in `site-packages` root
    conf_py = SP_DIR / "moocore/conftest.py"

    with TemporaryDirectory() as td:
        cwd = setup_test_cwd(td, conf_py)
        rc = max([do(cmd, cwd=cwd) for cmd in COV_CMDS])

    # clean up `site-packages`,
    conf_py.unlink()
    return rc


if __name__ == "__main__":
    sys.exit(main())
