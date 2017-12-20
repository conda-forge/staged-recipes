"""
Test of the lpsolve shared library using ctypes
"""

import ctypes
from ctypes import CDLL, c_int, byref
import sys
import os

if sys.platform == "win32":
    lib_name = "lpsolve55.dll"
    lib_path = os.path.join(sys.prefix, "Library", "bin", lib_name)
    lib = ctypes.windll.LoadLibrary(lib_path)
elif sys.platform == "darwin":
    lib_name = "liblpsolve55.dylib"
    lib_path = os.path.join(sys.prefix, "lib", lib_name)
    lib = CDLL(lib_path)
else:
    lib_name = "liblpsolve55.so"
    lib_path = os.path.join(sys.prefix, "lib", lib_name)
    lib = CDLL(lib_path)

major = c_int()
minor = c_int()
release = c_int()
build = c_int()

lib.lp_solve_version(byref(major), byref(minor), byref(release), byref(build))

assert(major.value == 5)
assert(minor.value == 5)

print("lpsolve version: {}.{}.{}.{}".format(major.value, minor.value, release.value, build.value))
