# run_test.py
import sys
import subprocess
import os

# First install the correct versions with pip
subprocess.check_call([sys.executable, "-m", "pip", "install", "typepigeon==1.0.5"])
subprocess.check_call([sys.executable, "-m", "pip", "install", "wget"])

# Now try importing pyschism
try:
    import pyschism
    print("Successfully imported pyschism")
    # Optionally test a basic functionality of pyschism
except ImportError as e:
    print(f"Failed to import pyschism: {e}")
    sys.exit(1)
