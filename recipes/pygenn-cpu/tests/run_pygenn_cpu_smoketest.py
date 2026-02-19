# recipe/tests/run_pygenn_cpu_smoketest.py
import sys

# ----------------------------
# Check backend availability
# ----------------------------
from pygenn.genn_model import backend_modules  # noqa: E402

cpu_backend = None
for cand in ("single_threaded_cpu", "openmp"):
    if cand in backend_modules:
        cpu_backend = cand
        break

if not cpu_backend:
    print(f"ERROR: No CPU backend found; available backends: {list(backend_modules.keys())}", file=sys.stderr)
    sys.exit(1)

# ----------------------------
# Minimal build+load smoke test
# ----------------------------
from pygenn import GeNNModel  # noqa: E402

model = GeNNModel("float", "cpu_smoke", backend=cpu_backend)
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
model.add_current_source("CurrentSource", "DC", pop, {"amp": 5.0}, {})

model.build()
model.load()

print(f"BUILD_AND_LOAD_OK ({cpu_backend})")
sys.exit(0)
