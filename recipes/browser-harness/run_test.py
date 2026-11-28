import os
import subprocess
from importlib.metadata import version

os.environ["BH_TELEMETRY"] = "0"
result = subprocess.run(["browser-harness", "--version"], check=True, capture_output=True, text=True)
assert result.stdout.strip() == version("browser-harness"), result.stdout
result = subprocess.run(["browser-harness", "--help"], check=True, capture_output=True, text=True)
assert "browser-harness" in result.stdout

# Exercise the harness image-resize path without launching a browser.
import base64
import io
from pathlib import Path
from tempfile import TemporaryDirectory
from unittest.mock import patch

from PIL import Image
from browser_harness import helpers

assert version("pillow") == "13.0.0"
image = io.BytesIO()
Image.new("RGB", (80, 40), "red").save(image, format="PNG")
response = {"data": base64.b64encode(image.getvalue()).decode()}
with TemporaryDirectory() as directory, patch.object(helpers, "cdp", return_value=response):
    output = helpers.capture_screenshot(str(Path(directory) / "shot.png"), max_dim=20)
    with Image.open(output) as resized:
        assert resized.size == (20, 10), resized.size
