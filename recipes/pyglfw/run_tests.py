import os
import sys

# Ensure the GLFW library can be found.
# CONDA_PREFIX = os.environ['CONDA_PREFIX']
#
# if sys.platform == 'linux':
#     os.environ['LD_LIBRARY_PATH'] = CONDA_PREFIX + os.path.sep + 'lib'
# elif sys.platform == 'darwin':
#     os.environ['DYLD_LIBRARY_PATH'] = CONDA_PREFIX + os.path.sep + 'lib'

# Run the actual tests.
import glfw
