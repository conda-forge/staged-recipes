import sys
import os
# On windows and python 2, the tests fail miserably due to a forced exit
# when the dll cannot be loaded.
if sys.version[0] == '2' and os.name == 'nt':
    exit(0)

try:
    # This is going to fail with an OSError complaining that the necessary
    # library isn't installed
    import ftd2xx
except OSError as e:
    pass
