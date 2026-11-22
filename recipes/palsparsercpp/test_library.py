"""Load the installed PALSParserCpp library from the environment alone, as
palsparserpy does, and check that it reports the version it is packaged as.

On Linux and macOS its rpath finds librapidyaml and pcre2 beside it in lib/;
on Windows their DLLs sit beside PALSParserCpp.dll in Library\\bin. A version
mismatch means a release was tagged without setting VERSION in the project()
call of CMakeLists.txt.
"""

import ctypes
import os
import sys

expected = sys.argv[1]
if sys.platform == "win32":
    path = os.path.join(sys.prefix, "Library", "bin", "PALSParserCpp.dll")
else:
    ext = "dylib" if sys.platform == "darwin" else "so"
    path = os.path.join(sys.prefix, "lib", "libPALSParserCpp." + ext)

lib = ctypes.CDLL(path)
version = lib.pals_parser_cpp_version
version.restype = ctypes.c_char_p
version.argtypes = []
reported = version().decode("ascii")
if reported != expected:
    sys.exit(f"{path} reports version {reported}, but the package is {expected}")
print(f"{path}: PALSParserCpp {reported}")
