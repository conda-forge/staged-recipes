import os
from pathlib import Path
import subprocess
import sys

import vst_audio

# Test the shipped worker, not an executable supplied by the surrounding shell.
os.environ.pop("VST_AUDIO_WORKER", None)
worker = Path(vst_audio.Host().worker)
package = Path(vst_audio.__file__).resolve().parent
assert worker.is_file(), worker
assert worker.is_relative_to(package / "_worker"), worker
assert os.access(worker, os.X_OK), worker

# This also checks the architecture and loader dependencies without a plugin,
# audio device, or desktop session.
subprocess.run([str(worker), "--help"], check=True, timeout=30)
if sys.platform == "darwin":
    subprocess.run(
        ["codesign", "--verify", "--strict", str(worker.parents[2])],
        check=True,
        timeout=30,
    )
