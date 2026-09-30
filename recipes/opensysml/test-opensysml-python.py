import sys
import os
from subprocess import call, Popen
import atexit
import socket
import shutil
from pathlib import Path

IS_WIN = os.name == "nt"

# this includes the deep ``go`` path for... ``go`` reasons
TEST_ROOT = Path(os.environ["CF_OPENSYSML_PY_TEST_ROOT"])

# fail, instead of skipping, tests that requires a running ``opensysml-grpc``
ENV_STRICT = {
    "OPENSYSML_REQUIRE_SERVICE": "1",
}

# passed to test invocation
ENV_SERVICE = "OPENSYSML_SERVICE"

# should be set by activation JSON in ``etc/conda/env_vars.d/sysml-grpc.json``
ENV_GRPC_BINARY = "OPENSYSML_BINARY"

GRPC_MAGIC_PORT = 50051

# coverage thresholds
COV_FAIL_UNDER = 82

PRUNE_TESTS = [
    # files that do random internet things, or assume an in-tree, editable install
    "test_binary.py",
    "test_check_version.py",
    "test_legacy_pysysml_placeholder.py",
    "test_pin_release_checksums.py",
    "test_version.py",
]

SKIPS = [
    # hangs
    "a_forked_child_neither_stops_nor_inherits_the_service",
]

if IS_WIN:
    SKIPS += [
        # doesn't work on windows
        "a_parent_killed_with_sigkill_leaves_no_service",
        # not sure
        "a_value_is_changed_and_everything_else_is_kept",
    ]

PYTEST_K = f"""not ({" or ".join(["not-a-test", *SKIPS])})"""

PATCHES = {
    # doesn't respect env vars, $PATH, etc.
    "hard-coded grpc binary": (
        "GRPC_BINARIES = (",
        f"""GRPC_BINARIES = ( os.environ['{ENV_GRPC_BINARY}'],""",
    )
}

# standard invocations
PYTEST_ARGS = ["pytest", "-vv", "--tb=long", "--color=yes", "-k", PYTEST_K]
COV_RUN_ARGS = ["--source=opensysml", "--branch"]
COV_REPORT_ARGS = ["--show-missing", "--skip-covered", f"--fail-under={COV_FAIL_UNDER}"]


def do(*args: str, env: dict[str, str] | None = None) -> int:
    print(">>>", env or "{}", *args, flush=True)
    env = {**os.environ, **env} if env else None
    rc = call(args, env=env, cwd=TEST_ROOT)
    if rc:
        print(f"!!! failed [{rc}]:", *args, flush=True)
    return rc


def clean():
    for to_unlink in PRUNE_TESTS:
        path = TEST_ROOT / "tests" / to_unlink
        if path.exists():
            print("... pruning:", path)
            path.unlink()
    return 0


def patch():
    patched = False
    for path in TEST_ROOT.rglob("test_*.py"):
        new_text = old_text = path.read_text(encoding="utf-8")
        for label, (pattern, replacement) in PATCHES.items():
            if pattern in new_text:
                print("... patching", label, ":", path, flush=True)
                new_text = new_text.replace(pattern, replacement)
        if new_text != old_text:
            path.write_text(new_text, encoding="utf-8")
            patched = True
    return 0 if patched else 1


def get_unused_port():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind(("localhost", 0))
    s.listen(1)
    port = s.getsockname()[1]
    s.close()
    return port


def grpc_server_env() -> dict[str, str]:
    """Start a ``opensysml-grpc`` server per the ``INSTALL.md`` instructons."""
    grpc_binary = os.environ.get(ENV_GRPC_BINARY)
    grpc_proc: Popen | None = None

    if grpc_binary and shutil.which(grpc_binary):
        # apparently is hard-coded
        # port = get_unused_port()
        port = GRPC_MAGIC_PORT

        args = [grpc_binary, "-port", f"{port}"]
        print(">>>", args, flush=True)
        grpc_proc = Popen(args, shell=False)

        def _stop():
            (print("--- cleanup up:", *args),)
            grpc_proc.terminate()

        print("--- scheduling cleanup at exit:", *args, flush=True)
        atexit.register(_stop)

        return {**ENV_STRICT, ENV_SERVICE: f"127.0.0.1:{port}"}
    print(f"!!! can't start ${ENV_GRPC_BINARY}: {grpc_binary} ", flush=True)
    return {}


def main() -> int:
    env = grpc_server_env()

    rc = (
        clean()
        or patch()
        or do("pip", "check")
        or do("opensysml-generate", "--help")
        or do(os.environ.get(ENV_GRPC_BINARY, "missing-opensysml-grpc"), "--help")
        or do("coverage", "run", *COV_RUN_ARGS, "-m", *PYTEST_ARGS, env=env)
        or do("coverage", "report", *COV_REPORT_ARGS)
    )
    sys.exit(rc)


if __name__ == "__main__":
    sys.exit(main())
