"""Verify plugin discovery and registration without creating a render window."""

import os
from importlib.metadata import version
from pathlib import Path

import imas_paraview
from paraview import servermanager
from paraview.simple import LoadPlugin

plugin_dir: Path = Path(imas_paraview.__file__).parent / "plugins"
assert plugin_dir.resolve() in {
    Path(path).resolve() for path in os.environ["PV_PLUGIN_PATH"].split(os.pathsep)
}
assert imas_paraview.__version__ == version("imas-paraview")
LoadPlugin(str(plugin_dir / "wall_limiter.py"), remote=False)
assert servermanager.ProxyManager().GetPrototypeProxy("sources", "WallLimiterReader")
