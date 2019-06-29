import sys

import psychopy
import psychopy.app
import psychopy.data
import psychopy.experiment
import psychopy.gui
import psychopy.hardware
import psychopy.monitors
import psychopy.preferences

# Only test audio on macOS for now.
if sys.platform == 'darwin':
    import psychopy.sound

# Disable problematic tests on Linux
# See https://github.com/conda-forge/staged-recipes/pull/8645
if sys.platform != 'linux':
    import psychopy.event
    import psychopy.visual

