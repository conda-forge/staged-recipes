# recipe/tests/run_pygenn_cuda_smoketest.py
import os
import sys
import shutil
import subprocess

# Prefer the test env's prefix that conda-build provides
prefix = os.environ.get("PREFIX") or os.environ.get("CONDA_PREFIX")
if not prefix:
    print("ERROR: PREFIX/CONDA_PREFIX not found; cannot set toolchain/CUDA_PATH", file=sys.stderr)
    sys.exit(1)

# ----------------------------
# Toolchain & CUDA env wiring
# ----------------------------
if os.name == "nt":
    # Windows: CUDA headers/libs/bin live under Library/
    cuda_path = os.path.join(prefix, "Library")
    os.environ["CUDA_PATH"] = cuda_path
    os.environ["CUDA_LIBRARY_PATH"] = os.path.join(cuda_path, "lib")
    os.environ["PATH"] = os.path.join(cuda_path, "bin") + os.pathsep + os.environ.get("PATH", "")
else:
    # POSIX: headers/libs/bin are directly under the prefix
    cuda_path = prefix
    os.environ["CUDA_PATH"] = cuda_path
    os.environ["PATH"] = os.path.join(cuda_path, "bin") + os.pathsep + os.environ.get("PATH", "")

    # Make sure runtime can find CUDA/conda libs
    ldpaths = [os.path.join(prefix, "lib")]
    old_ld = os.environ.get("LD_LIBRARY_PATH", "")
    if old_ld:
        ldpaths.append(old_ld)
    os.environ["LD_LIBRARY_PATH"] = ":".join(ldpaths)

    # Use the conda host compiler via CXX (GeNN's Makefile will pass -ccbin $(CXX))
    host_cxx = os.path.join(prefix, "bin", "x86_64-conda-linux-gnu-c++")
    if not os.path.exists(host_cxx):
        # Fallback to generic g++/c++
        host_cxx = shutil.which("g++") or shutil.which("c++") or host_cxx
    os.environ["CXX"] = host_cxx

    # Ensure CUDAHOSTCXX is NOT set (otherwise nvcc adds its own -ccbin too → duplicate)
    if "CUDAHOSTCXX" in os.environ:
        del os.environ["CUDAHOSTCXX"]

    # Helper to strip any pre-existing -ccbin/--compiler-bindir from NVCCFLAGS
    def _strip_ccbin(flags: str) -> str:
        toks = flags.split()
        out = []
        skip_next = False
        for t in toks:
            if skip_next:
                skip_next = False
                continue
            if t in ("-ccbin", "--compiler-bindir"):
                skip_next = True  # drop this and its value
                continue
            if t.startswith("-ccbin=") or t.startswith("--compiler-bindir="):
                continue
            out.append(t)
        return " ".join(out).strip()

    # Force C++17 for host and device; sanitize NVCCFLAGS first to avoid warnings
    os.environ["CXXFLAGS"] = (os.environ.get("CXXFLAGS", "") + " -std=gnu++17").strip()
    cleaned_nvcc = _strip_ccbin(os.environ.get("NVCCFLAGS", ""))
    os.environ["NVCCFLAGS"] = (cleaned_nvcc + " --std=c++17 -Xcompiler -std=gnu++17").strip()

print(f"Using CUDA_PATH={os.environ['CUDA_PATH']}")
if os.name != "nt":
    print(f"Using CXX={os.environ.get('CXX','<unset>')}")
    try:
        nvcc_v = subprocess.check_output(["nvcc", "--version"], text=True).strip().splitlines()[-1]
        print(f"nvcc: {nvcc_v}")
    except Exception:
        print("WARNING: nvcc --version failed (nvcc not on PATH?)")

# ----------------------------
# Check backend availability
# ----------------------------
from pygenn.genn_model import backend_modules  # noqa: E402
if "cuda" not in backend_modules:
    print(f"ERROR: 'cuda' backend not found; available backends: {list(backend_modules.keys())}", file=sys.stderr)
    sys.exit(1)

# On Windows, ensure MSVC toolchain exists for runtime compile (nmake + cl)
force_compile = os.environ.get("PYGENN_FORCE_COMPILE_TEST", "") == "1"
if os.name == "nt":
    have_nmake = shutil.which("nmake") is not None
    have_cl = shutil.which("cl") is not None
    if not (have_nmake and have_cl):
        msg = "MSVC toolchain (nmake/cl) not found; skipping build+load smoke test on Windows."
        if force_compile:
            print("ERROR: " + msg + " Set up VS build tools or install vs2022_win-64 in this env.", file=sys.stderr)
            sys.exit(1)
        else:
            print("WARNING: " + msg)
            from pygenn import GeNNModel  # noqa: E402
            print("IMPORT_OK_AND_CUDA_BACKEND_AVAILABLE")
            sys.exit(0)

# ----------------------------
# Minimal build+load smoke test
# ----------------------------
from pygenn import GeNNModel  # noqa: E402

model = GeNNModel("float", "tutorial1", backend="cuda")
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

# Ensure toolchain works and module loads
model.build()
model.load()

print("BUILD_AND_LOAD_OK")
