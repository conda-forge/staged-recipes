export LDFLAGS="-L$PREFIX/lib -L$PREFIX/lib64 -lncursesw -ltinfow $LDFLAGS"

# Use `sed -i.bak` to support both macOS and linux
# Add setuptools import to trigger monkey patching distutils
sed -i.bak 's/from distutils.core import/import setuptools\'$'\nfrom distutils.core import/' bindings/python/setup.py.in
# Tell setuptools not to handle dependencies
sed -i.bak 's/ --record PYTHON_INSTALLED/ --single-version-externally-managed --record=record.txt/' bindings/python/CMakeLists.txt
# Set the rpath for the python package
sed -i.bak 's/\[xrdlibdir, xrdcllibdir\]/[xrdlibdir, xrdcllibdir], extra_link_args=["-Wl,-rpath,${CMAKE_INSTALL_RPATH}"]/' bindings/python/setup.py.in

mkdir build
cd build

cmake \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DOPENSSL_ROOT_DIR="$PREFIX" \
    -DKERBEROS5_ROOT_DIR="$PREFIX" \
    -DPYTHON_EXECUTABLE=$(which python) \
    -DPYTHON_INCLUDE_DIR="${PREFIX}/lib/libpython${PY_VER}m${SHLIB_EXT}" \
    -DPYTHON_LIBRARY="$PREFIX/include/python${PY_VER}m" \
    -DCMAKE_INSTALL_RPATH="$PREFIX/lib64" \
    -DCMAKE_SKIP_BUILD_RPATH=ON \
    -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
    -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
    ..

make -j${NUM_CPUS}
make install
