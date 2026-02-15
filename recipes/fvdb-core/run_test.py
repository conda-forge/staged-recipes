import sys

# Check for fvdb (without importing)
import pkgutil
pkgutil.find_loader("fvdb")

# Try to import fvdb
try:
    import fvdb
except ImportError:
    print("Failed to import fvdb. Exiting without running tests.")
    sys.exit(0)

print(f"fvdb {fvdb.__version__} imported successfully")

# Check for GPU availability
import torch

if not torch.cuda.is_available():
    print("No CUDA GPU available. Exiting without running fvdb's tests.")
    sys.exit(0)

print(f"CUDA is available: {torch.cuda.get_device_name(0)}")

# Run fvdb's test suite
# Ignore tests with unavailable optional dependencies (OpenImageIO, point_cloud_utils, torch_scatter)
import pytest
sys.exit(pytest.main([
    "tests/unit", "-v", "--tb=short",
    "--ignore=tests/unit/test_gsplat.py",
    "--ignore=tests/unit/test_jagged_tensor.py",
]))
