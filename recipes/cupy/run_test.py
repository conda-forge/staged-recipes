# Configure CuPy to use 1 GPU for testing
import os
os.environ["CUPY_TEST_GPU_LIMIT"] = "1"

# Check for CuPy (without importing)
import pkgutil
pkgutil.find_loader("cupy")

# Try to import CuPy
import sys
try:
    import cupy
except ImportError:
    print("No GPU available. Exiting without running CuPy's tests.")
    sys.exit(0)

# Run CuPy's test suite
import py
py.test.cmdline.main(["tests/cupy_tests"])
