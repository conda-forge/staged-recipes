cmake \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILDPYTHONMODULE=ON \
  -DPython3_FIND_STRATEGY=LOCATION \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  ${CMAKE_ARGS} \
  -B build \
  .

cmake \
  --build \
  build \
  --target kahip_python_binding \
  -j${CPU_COUNT:-2}

cmake --install build --component python
