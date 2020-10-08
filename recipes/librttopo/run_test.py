import os
import sys
import ctypes

if sys.platform == 'win32':
    path = os.path.join(sys.prefix, 'Library', 'bin', 'librttopo.dll')
    libfreexl = ctypes.CDLL(path)
elif sys.platform == 'darwin':
    # LD_LIBRARY_PATH not set on OS X or Linux.
    path = os.path.expandvars('$PREFIX/lib/librttopo.dylib')
    libfreexl = ctypes.CDLL(path)
elif sys.platform.startswith('linux'):
    path = os.path.expandvars('$PREFIX/lib/librttopo.so')
    libfreexl = ctypes.CDLL(path)
else:
    raise Exception('Cannot recognize platform {!r}'.format(sys.platform))
