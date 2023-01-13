# also explcitily build shared libs,
# which makes libkahip_static a _shared_ library,
# which mostly bundles references to libkahip and friends
# but don't remove it, since some things (e.g. kahip-python) link it.

# don't build Python in the first go
# we'll do that in build-kahip-python

cmake \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILDPYTHONMODULE=OFF \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  ${CMAKE_ARGS} \
  -B build \
  .

cmake \
  --build \
  build \
  -j${CPU_COUNT:-2}

cmake --install build
