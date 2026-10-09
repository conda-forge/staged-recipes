from __future__ import annotations

import hashlib
import importlib.metadata
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

from conda_ship.cli import resolve_cs


def run(
    *args: str | Path,
    success: bool = True,
    env: dict[str, str] | None = None,
) -> str:
    """Capture subprocess diagnostics without exposing build or test prefixes."""
    result = subprocess.run(
        [str(arg) for arg in args],
        capture_output=True,
        text=True,
        timeout=60,
        env=env,
    )
    assert (result.returncode == 0) == success, (
        f"{Path(args[0]).name} exited with status {result.returncode}"
    )
    return result.stdout + result.stderr


for name in list(os.environ):
    if name.startswith(("CONDA_SHIP_", "CS_TEMPLATE_")) or name in {
        "CONDA_NO_PLUGINS",
        "LD_LIBRARY_PATH",
        "DYLD_LIBRARY_PATH",
        "DYLD_FALLBACK_LIBRARY_PATH",
    }:
        os.environ.pop(name)

installed = json.loads(run(sys.executable, "-m", "conda", "list", "--json", "^conda-ship$"))
assert installed[0]["version"] == importlib.metadata.version("conda-ship")
builder = resolve_cs().path
template = builder.with_name("cs-template.exe" if os.name == "nt" else "cs-template")
assert template.is_file(), "The runtime template must be installed beside the builder"
assert "Build ready-to-run conda runtimes" in run(builder, "--help")
run(builder, "package-update", "--help")
assert "Build ready-to-run conda runtimes" in run(
    sys.executable, "-m", "conda_ship.cli", "--help"
)
assert "Build ready-to-run conda runtimes" in run(
    sys.executable, "-m", "conda", "ship", "--", "--help"
)


with tempfile.TemporaryDirectory() as temporary:
    root = Path(temporary)
    fixture = root / "fixture"
    shutil.copytree("tests/fixtures/structural-runtime", fixture)
    copied_template = root / template.name
    shutil.copy2(template, copied_template)
    runtime_env = os.environ.copy()
    if os.name == "nt":
        system_root = Path(os.environ["SystemRoot"])
        runtime_env["PATH"] = os.pathsep.join((str(system_root), str(system_root / "System32")))
    if sys.platform == "darwin" and shutil.which("otool"):
        linkage = run("otool", "-L", copied_template)
        libraries = [line.split()[0] for line in linkage.splitlines()[1:]]
        assert all(name.startswith(("/usr/lib/", "/System/Library/")) for name in libraries), (
            "The runtime template links a non-system shared library"
        )
    elif sys.platform.startswith("linux") and shutil.which("ldd"):
        linkage = run("ldd", copied_template)
        assert "not found" not in linkage, "The runtime template has an unresolved shared library"
        libraries = re.findall(r"(/[\S]+)", linkage)
        system_paths = ("/lib/", "/lib64/", "/usr/lib/", "/usr/lib64/")
        assert all(name.startswith(system_paths) for name in libraries), (
            "The runtime template links a non-system shared library"
        )
    assert "is a runtime template, not a runnable conda runtime" in run(
        copied_template, success=False, env=runtime_env
    )

    output = root / "output"
    run(builder, "build", "--root", fixture, "--out-dir", output)
    manifests = list(output.glob("*.sha256"))
    assert len(manifests) == 1, "Expected one checksum manifest"
    entries = manifests[0].read_text().splitlines()
    assert entries, "The checksum manifest must not be empty"
    for entry in entries:
        digest, filename = entry.split(maxsplit=1)
        artifact = output / filename.lstrip("*")
        assert hashlib.sha256(artifact.read_bytes()).hexdigest() == digest, (
            "A generated artifact does not match its checksum"
        )
    assert len(list(output.glob("*.info.json"))) == 1
    assert len(list(output.glob("*.cdx.json"))) == 1

    runtime = output / ("structural-runtime.exe" if os.name == "nt" else "structural-runtime")
    invalid_prefix = root / "not-a-directory"
    invalid_prefix.write_text("This prevents bootstrap before any package request.")
    assert "refusing to use install path that is not a directory" in run(
        runtime,
        "--help",
        success=False,
        env={**runtime_env, "CONDA_SHIP_PREFIX": str(invalid_prefix)},
    )

print("Installed CLI, conda plugin, runtime template, stamping, and checksums verified")
