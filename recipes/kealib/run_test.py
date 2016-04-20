
# just load kealib using ctypes
import sys
import ctypes

if sys.platform == 'win32':
    kealib = ctypes.CDLL('libkea.dll')
elif sys.platform == 'darwin':
    kealib = ctypes.CDLL('libkea.dylib')
else:
    kealib = ctypes.CDLL('libkea.so')

