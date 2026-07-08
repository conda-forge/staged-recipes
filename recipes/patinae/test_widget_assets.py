import base64
from pathlib import Path

import patinae
import patinae._patinae
import patinae.widget as widget_pkg
from patinae import cmd
from patinae.widget import Viewer

widget_dir = Path(widget_pkg.__file__).parent
required = [
    widget_dir / "_frontend.js",
    widget_dir / "static" / "patinae-viewer.js",
    widget_dir / "static" / "patinae_web_glue.js",
    widget_dir / "static" / "patinae_web_bg.wasm",
]

for path in required:
    assert path.is_file(), path
    assert path.stat().st_size > 0, path

viewer = Viewer(width="10px", height="10px")
assert "WebViewer" in viewer._glue_js
assert (
    len(base64.b64decode(viewer._wasm_b64))
    == (widget_dir / "static" / "patinae_web_bg.wasm").stat().st_size
)

widget_cmd = viewer.get_cmd()
assert callable(widget_cmd.fetch)
assert callable(widget_cmd.show)
