import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

from pyenergyplus.api import EnergyPlusAPI


prefix = Path(sys.prefix).resolve()
root = prefix / "Library" if sys.platform == "win32" else prefix
for relative in (
    "ExampleFiles", "python_lib", "PreProcess/EP-Launch-Lite.app",
    "PreProcess/IDFVersionUpdater/IDFVersionUpdater.app",
    "PreProcess/EPDraw", "PreProcess/IDFEditor", "EP-Launch.exe",
):
    if (root / relative).exists():
        raise AssertionError(f"Unexpected optional package content: {relative}")
if sys.platform != "win32" and list(root.glob("libpython*")):
    raise AssertionError("Unexpected bundled Python shared library")
if sys.platform == "win32" and list(root.glob("python3*.dll")):
    raise AssertionError("Unexpected bundled Python DLL in Library")
if sys.platform == "win32":
    updater = root / "PreProcess/IDFVersionUpdater"
    if (updater / "IDFVersionUpdater.exe").exists() or list(updater.glob("*.dll")):
        raise AssertionError("Unexpected Windows updater GUI runtime")
    if (root / "PreProcess/WeatherConverter/Weather.exe").exists():
        raise AssertionError("Unexpected Windows weather converter GUI")

fixture = Path("testfiles/PythonPlugin1ZoneUncontrolledCondFD.idf")
plugin = fixture.with_suffix(".py")
if not fixture.is_file() or not plugin.is_file():
    raise FileNotFoundError("Upstream Python-plugin test fixtures are missing")

probe = """

import ctypes
import _lzma
import _sqlite3
import json
import lzma
from pathlib import Path
import sqlite3
import ssl
import sys

_original_callback = CondFDSurfaceManager.on_begin_timestep_before_predictor

def _verified_callback(self, state):
    result = _original_callback(self, state)
    marker = Path(__file__).with_name("plugin-executed.json")
    if not self.api.exchange.warmup_flag(state) and not marker.exists():
        assert lzma.decompress(lzma.compress(b"conda-python")) == b"conda-python"
        with sqlite3.connect(":memory:") as database:
            assert database.execute("select 26").fetchone() == (26,)
        ssl.create_default_context()
        assert ctypes.sizeof(ctypes.c_double) == 8
        marker.write_text(json.dumps({
            "prefix": sys.prefix,
            "stdlib": json.__file__,
            "extensions": [ssl._ssl.__file__, _sqlite3.__file__, _lzma.__file__],
            "temperature": self.api.exchange.get_variable_value(state, self.zone_air_temp_handle),
        }))
    return result

CondFDSurfaceManager.on_begin_timestep_before_predictor = _verified_callback
"""

with tempfile.TemporaryDirectory(prefix="energyplus-plugin-") as directory:
    work = Path(directory)
    model = work / fixture.name
    model.write_bytes(fixture.read_bytes())
    (work / plugin.name).write_text(plugin.read_text() + probe)
    environment = os.environ.copy()
    environment["PYTHONPATH"] = str(work / "nonexistent-pythonpath")
    environment["PYTHONHOME"] = str(work / "nonexistent-pythonhome")
    command = ["energyplus", "-D", "-d", str(work / "output"), str(model)]
    # cmd.exe resolves the conda PATH wrapper on Windows.
    if sys.platform == "win32":
        command = ["cmd", "/d", "/c", *command]
    result = subprocess.run(command, cwd=work, env=environment, timeout=300)
    if result.returncode:
        errors = work / "output/eplusout.err"
        if errors.is_file():
            print(errors.read_text(), flush=True)
        result.check_returncode()
    marker = json.loads((work / "plugin-executed.json").read_text())
    if Path(marker["prefix"]).resolve() != prefix:
        raise AssertionError(f"Embedded Python uses the wrong prefix: {marker}")
    for path in [marker["stdlib"], *marker["extensions"]]:
        if not Path(path).resolve().is_relative_to(prefix):
            raise AssertionError(f"Python module loaded outside the conda environment: {path}")
    errors = (work / "output/eplusout.err").read_text()
    if "EnergyPlus Completed Successfully" not in errors or "**  Fatal  **" in errors:
        raise AssertionError(errors)
    if not (work / "output/eplusout.eso").stat().st_size:
        raise AssertionError("Simulation produced no output")
    api = EnergyPlusAPI()
    state = api.state_manager.new_state()
    try:
        if not state:
            raise AssertionError("Python API could not allocate a simulation state")
    finally:
        api.state_manager.delete_state(state)
    print("Python plugin executed using conda Python:", json.dumps(marker), flush=True)
