# run_test.py
import sys
import subprocess
import os


subprocess.check_call([sys.executable, "-m", "pip", "install", "typepigeon==1.0.5"])
subprocess.check_call([sys.executable, "-m", "pip", "install", "wget"])


try:
    import pyschism
    print("Successfully imported pyschism")
except ImportError as e:
    print(f"Failed to import pyschism: {e}")
    sys.exit(1)
