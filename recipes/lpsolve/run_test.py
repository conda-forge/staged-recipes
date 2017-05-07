"""
Test of the lpsolve shared library using ctypes
"""

from ctypes import *

lib = CDLL("lpsolve55.dll")

major = c_int()
minor = c_int()
release = c_int()
build = c_int()

lib.lp_solve_version(byref(major), byref(minor), byref(release), byref(build))

assert(major.value == 5)
assert(minor.value == 5)

print("lpsolve version: {}.{}.{}.{}".format(major.value, minor.value, release.value, build.value))
