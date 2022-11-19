# A simplified builder.py because conda(-forgE)
# manages packages and build environments instead of
# conan
import platform
from cffi import FFI
from importlib_resources import read_text

import webp_build

libraries = ['webp', 'webpmux', 'webpdemux']
if platform.system() == 'Windows':
    libraries = [f"lib{lib}" for lib in libraries]

# Specify C sources to be build by CFFI
ffibuilder = FFI()
ffibuilder.set_source(
    '_webp',
    read_text(webp_build, 'source.c'),
    libraries=libraries,
)
ffibuilder.cdef(read_text(webp_build, 'cdef.h'))


if __name__ == '__main__':
    ffibuilder.compile(verbose=True)
