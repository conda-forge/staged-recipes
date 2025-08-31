# recipe/tests/run_pygenn_cuda_smoketest.py
import os
import sys
import ctypes

# Prefer the conda-build provided prefixes
prefix = os.environ.get("PREFIX") or os.environ.get("CONDA_PREFIX")
if not prefix:
    print("ERROR: PREFIX/CONDA_PREFIX not found; cannot configure toolchain/CUDA_PATH", file=sys.stderr)
    sys.exit(1)

# ----------------------------
# Toolchain & CUDA env wiring
# ----------------------------
if os.name == "nt":
    # Windows: modular CUDA lives under Library/
    cuda_path = os.path.join(prefix, "Library")
    os.environ["CUDA_PATH"] = cuda_path
    os.environ["CUDA_LIBRARY_PATH"] = os.path.join(cuda_path, "lib")
    os.environ["PATH"] = os.path.join(cuda_path, "bin") + os.pathsep + os.environ.get("PATH", "")
else:
    # Linux: modular CUDA headers/libs/bin live directly under the prefix
    cuda_path = prefix
    os.environ["CUDA_PATH"] = cuda_path
    os.environ["PATH"] = os.path.join(prefix, "bin") + os.pathsep + os.environ.get("PATH", "")

    # Make sure loader can find both libcudart and the driver stub from modular CUDA
    ld_candidates = [
        os.path.join(prefix, "lib"),
        os.path.join(prefix, "targets", "x86_64-linux", "lib"),
        os.path.join(prefix, "targets", "x86_64-linux", "lib", "stubs"),
    ]
    ld_existing = [p for p in ld_candidates if os.path.isdir(p)]
    os.environ["LD_LIBRARY_PATH"] = ":".join(ld_existing + [os.environ.get("LD_LIBRARY_PATH", "")]).strip(":")

    # Prefer the conda host C++ compiler (so nvcc picks a compatible ccbin)
    host_cxx = os.path.join(prefix, "bin", "x86_64-conda-linux-gnu-c++")
    if os.path.exists(host_cxx):
        os.environ["CXX"] = host_cxx

    # Avoid conflicts with pre-set CUDAHOSTCXX in CI containers
    os.environ.pop("CUDAHOSTCXX", None)

    # Strip any pre-existing -ccbin flags from NVCCFLAGS (we inject CXX above)
    def _strip_ccbin(flags: str) -> str:
        toks, out, skip = flags.split(), [], False
        for t in toks:
            if skip:
                skip = False
                continue
            if t in ("-ccbin", "--compiler-bindir"):
                skip = True
                continue
            if t.startswith("-ccbin=") or t.startswith("--compiler-bindir="):
                continue
            out.append(t)
        return " ".join(out)

    cleaned = _strip_ccbin(os.environ.get("NVCCFLAGS", ""))
    # Encourage C++17 both for host and device; keep user flags intact otherwise
    nvccflags = (cleaned + " --std=c++17 -Xcompiler -std=gnu++17").strip()
    os.environ["NVCCFLAGS"] = nvccflags
    os.environ["CXXFLAGS"] = (os.environ.get("CXXFLAGS", "") + " -std=gnu++17").strip()

# ----------------------------
# Quick visibility for logs
# ----------------------------
print("PREFIX:", prefix)
print("CUDA_PATH:", os.environ.get("CUDA_PATH"))
if os.name != "nt":
    print("LD_LIBRARY_PATH:", os.environ.get("LD_LIBRARY_PATH", ""))
print("PATH head:", os.environ.get("PATH", "")[:200], "...")

# ----------------------------
# Detect real NVIDIA driver and soft-skip if absent
# ----------------------------
def _driver_available() -> bool:
    try:
        if os.name == "nt":
            ctypes.WinDLL("nvcuda.dll")
        else:
            try:
                ctypes.CDLL("libcuda.so.1")
            except OSError:
                # WSL fallback: many images expose the driver here
                if os.path.isdir("/usr/lib/wsl/lib"):
                    os.environ["LD_LIBRARY_PATH"] = "/usr/lib/wsl/lib:" + os.environ.get("LD_LIBRARY_PATH", "")
                    ctypes.CDLL("libcuda.so.1")
                else:
                    raise
        return True
    except OSError as e:
        print(f"SKIP: No NVIDIA driver loadable ({e}). CUDA runtime tests skipped.")
        return False

if not _driver_available():
    # Exit success so conda-forge CI passes when no GPU/driver is present
    sys.exit(0)

# ----------------------------
# Check available backends
# ----------------------------
from pygenn.genn_model import backend_modules
print("Backends found:", list(backend_modules.keys()))

if "cuda" not in backend_modules:
    print(f"ERROR: CUDA backend not found (found {list(backend_modules.keys())})", file=sys.stderr)
    sys.exit(1)

# ----------------------------
# Minimal build+load test
# ----------------------------
from pygenn import GeNNModel

model = GeNNModel("float", "cuda_smoke", backend="cuda")
model.dt = 0.1

izk_init = {
    "V": -65.0,
    "U": -20.0,
    "a": [0.02, 0.1, 0.02, 0.02],
    "b": [0.2, 0.2, 0.2, 0.2],
    "c": [-65.0, -65.0, -50.0, -55.0],
    "d": [8.0, 2.0, 2.0, 4.0],
}

pop = model.add_neuron_population("Neurons", 4, "IzhikevichVariable", {}, izk_init)
model.add_current_source("CurrentSource", "DC", pop, {"amp": 10.0}, {})

model.build()
model.load()

print("BUILD_AND_LOAD_OK (cuda)")
