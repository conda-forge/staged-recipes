# recipe/tests/run_pygenn_cuda_smoketest.py
import os
import sys
import shutil

prefix = os.environ.get("PREFIX") or os.environ.get("CONDA_PREFIX")
if not prefix:
    print("ERROR: PREFIX/CONDA_PREFIX not found", file=sys.stderr)
    sys.exit(1)

# ----------------------------
# Toolchain & CUDA setup
# ----------------------------
if os.name == "nt":
    # Windows: CUDA under Library/
    cuda_path = os.path.join(prefix, "Library")
    os.environ["CUDA_PATH"] = cuda_path
    os.environ["CUDA_LIBRARY_PATH"] = os.path.join(cuda_path, "lib")
    os.environ["PATH"] = os.path.join(cuda_path, "bin") + os.pathsep + os.environ.get("PATH", "")
else:
    # Linux: CUDA directly under prefix
    cuda_path = prefix
    os.environ["CUDA_PATH"] = cuda_path
    os.environ["PATH"] = os.path.join(cuda_path, "bin") + os.pathsep + os.environ.get("PATH", "")
    os.environ["LD_LIBRARY_PATH"] = (
        os.path.join(prefix, "lib") + ":" + os.environ.get("LD_LIBRARY_PATH", "")
    )

    # Ensure nvcc uses conda’s compiler
    host_cxx = os.path.join(prefix, "bin", "x86_64-conda-linux-gnu-c++")
    if os.path.exists(host_cxx):
        os.environ["CXX"] = host_cxx

    # Avoid conflicts if CUDAHOSTCXX is set
    os.environ.pop("CUDAHOSTCXX", None)

    # Strip pre-existing -ccbin flags from NVCCFLAGS
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
    os.environ["NVCCFLAGS"] = (cleaned + " --std=c++17 -Xcompiler -std=gnu++17").strip()
    os.environ["CXXFLAGS"] = (os.environ.get("CXXFLAGS", "") + " -std=gnu++17").strip()

# ----------------------------
# Check CUDA backend
# ----------------------------
from pygenn.genn_model import backend_modules

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