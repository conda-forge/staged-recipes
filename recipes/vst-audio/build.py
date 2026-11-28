"""Cross-platform rattler-build script for the Python extension and worker."""

from __future__ import annotations

import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(os.environ.get("SRC_DIR", Path.cwd())).resolve()
PYTHON_BINDING = ROOT / "bindings" / "python"


def run(*command: os.PathLike[str] | str, cwd: Path = ROOT, env: dict[str, str] | None = None) -> None:
    print("+", " ".join(map(str, command)), flush=True)
    subprocess.run(list(map(str, command)), cwd=cwd, env=env, check=True)


def keep_runtime_frameworks(env: dict[str, str]) -> None:
    """Drop -dead_strip_dylibs from conda-forge's macOS link flags.

    The worker reaches AppKit only through the Objective-C runtime (objc2 looks
    NSApplication up by name), so the linker sees no AppKit symbol and that
    flag removes the framework: the worker then panics at start with "class
    NSApplication could not be found".
    """
    for name, value in list(env.items()):
        if "dead_strip_dylibs" not in value:
            continue
        separator = "\x1f" if name == "CARGO_ENCODED_RUSTFLAGS" else " "
        kept: list[str] = []
        for token in value.split(separator):
            if "dead_strip_dylibs" in token:
                if kept and kept[-1] == "-C":
                    kept.pop()  # "-C link-arg=-Wl,-dead_strip_dylibs"
                continue
            kept.append(token)
        env[name] = separator.join(kept)
        print(f"build.py: removed -dead_strip_dylibs from {name}", flush=True)


def main() -> None:
    env = dict(os.environ)
    if sys.platform == "darwin":
        keep_runtime_frameworks(env)
    # Keep all Cargo products in rattler-build's disposable work tree rather
    # than a checkout-adjacent or shared Cargo target directory.
    env["CARGO_TARGET_DIR"] = str(ROOT / "target" / "conda")
    env["CARGO_HOME"] = str(ROOT / ".cargo-home")
    if env.get("CPU_COUNT"):
        env.setdefault("CARGO_BUILD_JOBS", env["CPU_COUNT"])
    env["CARGO_PROFILE_RELEASE_STRIP"] = "symbols"

    # This interpreter comes from requirements.build and is Python >=3.11;
    # stage_worker imports tools/package_worker.py, which uses tomllib.
    run(sys.executable, PYTHON_BINDING / "stage_worker.py", env=env)

    host_python = env.get("PYTHON")
    if not host_python:
        raise RuntimeError("rattler-build did not define the host PYTHON executable")
    env["MATURIN_PEP517_ARGS"] = "--locked"
    # conda-forge's Rust activation names the target triple, also when osx-64
    # cross-compiles osx-arm64.
    if env.get("CARGO_BUILD_TARGET"):
        env["MATURIN_PEP517_ARGS"] += f" --target {env['CARGO_BUILD_TARGET']}"
    if env.get("CONDA_BUILD_CROSS_COMPILATION") == "1":
        env["PYO3_CROSS"] = "1"
        env["PYO3_CROSS_LIB_DIR"] = str(Path(env["PREFIX"]) / "lib")
        env["PYO3_CROSS_PYTHON_VERSION"] = env.get("PY_VER", "")
    if sys.platform == "win32":
        env["PYO3_PYTHON"] = host_python
    run(host_python, "-m", "pip", "install", PYTHON_BINDING, "-vv", "--no-deps",
        "--no-build-isolation", env=env)

    run("cargo-bundle-licenses", "--format", "yaml", "--output",
        ROOT / "THIRDPARTY-worker.yml", env=env)
    run("cargo-bundle-licenses", "--format", "yaml", "--output",
        PYTHON_BINDING / "THIRDPARTY-extension.yml", cwd=PYTHON_BINDING, env=env)


if __name__ == "__main__":
    main()
