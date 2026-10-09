# The installed package imports, runs host work, and reports its CUDA backend.
# The build machines have no NVIDIA driver: eagle must still import, and it
# must not load the CUDA runtime or driver libraries on its own.
import pathlib

import eagle
import eagle._core
import eagle.exec

assert eagle.exec.fold("sum", [1.0, 2.0]) == 3.0
backend = eagle._core.cuda_backend()
print("cuda backend:", {k: backend[k] for k in ("loaded", "path", "error")})
assert pathlib.Path(backend["path"]).is_file(), backend["path"]
if not backend["loaded"]:
    try:
        eagle._core.Stream()
    except eagle.BackendUnavailable as e:
        print("typed refusal:", e)
    else:
        raise SystemExit("Stream() did not refuse without a driver")

maps = pathlib.Path("/proc/self/maps").read_text()
assert "libcudart" not in maps, "eagle loaded the CUDA runtime"
print("eagle host smoke OK")
