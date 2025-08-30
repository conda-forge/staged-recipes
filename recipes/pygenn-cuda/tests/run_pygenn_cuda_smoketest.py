import sys
from pygenn.genn_model import backend_modules
if "cuda" not in backend_modules:
    print(f"ERROR: CUDA backend not found; got {list(backend_modules.keys())}", file=sys.stderr)
    sys.exit(1)

from pygenn import GeNNModel
m = GeNNModel("float", "smoketest", backend="cuda")
print("IMPORT_AND_BACKEND_OK")
