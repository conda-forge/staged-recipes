"""Load the zsasa shared library and check it through its C API."""

import ctypes
import os
import sys

expected_version = sys.argv[1]
prefix = os.environ.get("CONDA_PREFIX", sys.prefix)

if sys.platform == "win32":
    path = os.path.join(prefix, "Library", "bin", "zsasa.dll")
elif sys.platform == "darwin":
    path = os.path.join(prefix, "lib", "libzsasa.dylib")
else:
    path = os.path.join(prefix, "lib", "libzsasa.so")

lib = ctypes.CDLL(path)

lib.zsasa_version.restype = ctypes.c_char_p
version = lib.zsasa_version().decode()
assert version == expected_version, f"zsasa_version() = {version!r}, expected {expected_version!r}"

# Shrake-Rupley on a single atom: the accessible surface is the whole sphere
# of radius (atom radius + probe radius), 4*pi*(1.8+1.4)^2 = 128.68 A^2.
c_double_p = ctypes.POINTER(ctypes.c_double)
lib.zsasa_calc_sr.restype = ctypes.c_int
lib.zsasa_calc_sr.argtypes = [
    c_double_p, c_double_p, c_double_p, c_double_p,
    ctypes.c_size_t, ctypes.c_uint32, ctypes.c_double, ctypes.c_size_t,
    c_double_p, c_double_p,
]
zero = (ctypes.c_double * 1)(0.0)
radius = (ctypes.c_double * 1)(1.8)
atom_areas = (ctypes.c_double * 1)()
total = ctypes.c_double()
status = lib.zsasa_calc_sr(zero, zero, zero, radius, 1, 100, 1.4, 1, atom_areas, ctypes.byref(total))
assert status == 0, f"zsasa_calc_sr returned {status}"
assert abs(total.value - 128.68) < 0.01, f"total area {total.value}, expected 128.68"

print(f"{path}: version {version}, single-atom area {total.value:.2f}")
