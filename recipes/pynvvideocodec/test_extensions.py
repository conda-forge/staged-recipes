"""Exercise the native modules without invoking the driver's version query."""
import importlib.metadata
import importlib.util
import os
import subprocess
import sys
import tempfile
from pathlib import Path


dist = importlib.metadata.distribution("pynvvideocodec")
assert dist.version == "2.2.3"
package_dir = Path(dist.locate_file("PyNvVideoCodec"))


def load_extension(stem, module_name):
    suffix = "pyd" if sys.platform == "win32" else "so"
    paths = list(package_dir.glob(f"{stem}.*.{suffix}"))
    assert len(paths) == 1, (stem, paths)
    spec = importlib.util.spec_from_file_location(module_name, paths[0])
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


version_check = load_extension("VersionCheck", "VersionCheck")
assert hasattr(version_check, "DriverWrapper")
if len(sys.argv) > 1:
    codec = load_extension(f"PyNvVideoCodec_{sys.argv[1]}", "_PyNvVideoCodec")
    assert callable(codec.CreateDemuxer)
    assert hasattr(codec, "PyNvEncoder")
else:
    # Each variant gets its own process to avoid duplicate pybind11 registrations.
    if sys.platform == "win32":
        for suffix in ("121", "130"):
            subprocess.run([sys.executable, __file__, suffix], check=True)
    else:
        # The CUDA stub supplies link symbols without requiring an installed driver.
        stub = Path(sys.prefix) / "lib/stubs/libcuda.so"
        assert stub.is_file(), stub
        with tempfile.TemporaryDirectory() as directory:
            (Path(directory) / "libcuda.so.1").symlink_to(stub)
            env = dict(os.environ, LD_LIBRARY_PATH=directory)
            for suffix in ("121", "130"):
                subprocess.run([sys.executable, __file__, suffix], env=env, check=True)
