import json
import subprocess
import sys
from pathlib import Path

import pyspiel


# Play a deterministic complete game. Player 0 wins across the top row.
game = pyspiel.load_game("tic_tac_toe")
state = game.new_initial_state()
for action in (0, 3, 1, 4, 2):
    assert action in state.legal_actions()
    state.apply_action(action)

assert state.is_terminal()
assert state.returns() == [1.0, -1.0]

# Ensure no private copies of dependencies replaced by conda-forge packages
# leaked into the installed payload.
metadata_files = sorted((Path(sys.prefix) / "conda-meta").glob("open-spiel-*.json"))
assert len(metadata_files) == 1, metadata_files
files = json.loads(metadata_files[0].read_text(encoding="utf-8"))["files"]
forbidden = (
    "abseil-cpp",
    "nlohmann",
    "pybind11/include",
    "pybind11_abseil",
    "pybind11_json/include",
)
unexpected = sorted(path for path in files if any(item in path for item in forbidden))
assert not unexpected, f"Unexpected vendored dependency files: {unexpected}"

unexpected_sources = sorted(
    path
    for path in files
    if "/site-packages/open_spiel/" in path.replace("\\", "/").lower()
    and Path(path).suffix.lower() in {".c", ".cc", ".cpp", ".h", ".hpp"}
)
assert not unexpected_sources, f"Unexpected C/C++ sources in payload: {unexpected_sources}"

# The extension should resolve Abseil from the conda environment rather than
# embedding OpenSpiel's bundled source copy.
extension = Path(pyspiel.__file__).resolve()
if sys.platform.startswith("linux"):
    linkage = subprocess.check_output(["ldd", extension], text=True)
    assert "libabsl_" in linkage, linkage
elif sys.platform == "darwin":
    linkage = subprocess.check_output(["otool", "-L", extension], text=True)
    assert "libabsl_" in linkage, linkage
