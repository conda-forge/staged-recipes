import sys
import os

sys.path.insert(0, os.path.join(os.environ["PREFIX"], "Lib", "site-packages"))
try:
    import hatchling.build

    print("Successfully imported hatchling.build")
except ImportError as e:
    print(f"Failed to import hatchling.build: {e}")
    sys.exit(1)
