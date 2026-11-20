import os
import subprocess
from importlib.metadata import version

os.environ["BH_TELEMETRY"] = "0"
result = subprocess.run(["browser-harness", "--version"], check=True, capture_output=True, text=True)
assert result.stdout.strip() == version("browser-harness"), result.stdout
result = subprocess.run(["browser-harness", "--help"], check=True, capture_output=True, text=True)
assert "browser-harness" in result.stdout
