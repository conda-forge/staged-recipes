import os
import sys
import ctypes
import platform

if sys.platform == 'win32':
    lib = ctypes.CDLL('xerces-c_3_1.dll')
elif sys.platform == 'darwin':
    # LD_LIBRARY_PATH not set on OSX or Linux
    path = os.path.expandvars('$PREFIX/lib/libxerces-c.dylib')
    lib = ctypes.CDLL(path)
else:
    path = os.path.expandvars('$PREFIX/lib/libxerces-c.so')
    lib = ctypes.CDLL(path)
