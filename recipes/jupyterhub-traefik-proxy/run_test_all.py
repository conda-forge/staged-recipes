import sys
import subprocess
import platform
from pathlib import Path

HERE = Path(__file__).parent

# pytest arg inputs... etcd is available on conda-forge, so  _could_ be tested, but...
SKIPS = ["etcd", "consul"]
# slightly higher locally, but...
COV_FAIL_UNDER = 70

# osx-specific skips
if platform.system() == "Darwin":
    SKIPS += ["(add_get_delete and external_file_proxy_toml)"]

PYTEST_ARGS = [
    sys.executable,
    "-m",
    "pytest",
    "-vv",
    "--asyncio-mode=auto",
    "--cov=jupyterhub_traefik_proxy",
    "--cov-report=term-missing:skip-covered",
    "--no-cov-on-fail",
    f"--cov-fail-under={COV_FAIL_UNDER}",
    "-k",
    f"""not ({" or ".join(SKIPS)})""",
]

if __name__ == "__main__":
    print("\t".join(PYTEST_ARGS))
    sys.exit(subprocess.call(PYTEST_ARGS))
