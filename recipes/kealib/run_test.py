
# just load kealib using ctypes
import os
import sys
import ctypes

if sys.platform == 'win32':
    kealib = ctypes.CDLL('libkea.dll')
elif sys.platform == 'darwin':
    # LD_LIBRARY_PATH not set on OSX
    keapath = os.path.expandvars('$PREFIX/lib/libkea.dylib')
    kealib = ctypes.CDLL(keapath)
else:
    kealib = ctypes.CDLL('libkea.so')

