#!/bin/bash
set -euxo pipefail

# OpenMVS keeps state in function-local statics of inline functions; with
# shared libraries, -fvisibility-inlines-hidden gives every library its own
# copy (patch 0005 fixes the logger, which made the tools print nothing).
export CXXFLAGS="${CXXFLAGS//-fvisibility-inlines-hidden/}"

if [[ "${cuda_compiler_version:-None}" != "None" ]]; then
  CUDA_ARGS="-DOpenMVS_USE_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=all-major"
else
  CUDA_ARGS="-DOpenMVS_USE_CUDA=OFF"
fi

# MIME_UPDATE_CMD: do not run update-mime-database at install time (writes a
# cache into the package; upstream's install(CODE) for it is also malformed).
# OpenMVS adds its own -msse*/-mavx* flags; leave instruction sets to the
# compiler flags from x86_64-microarch-level instead.
cmake -S . -B build -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON \
  -DVCG_DIR=$PREFIX/include/vcglib \
  ${CUDA_ARGS} \
  -DOpenMVS_USE_PYTHON=OFF \
  -DOpenMVS_BUILD_VIEWER=ON \
  -DMIME_UPDATE_CMD=MIME_UPDATE_CMD-NOTFOUND \
  -DOpenMVS_USE_BREAKPAD=OFF \
  -DOpenMVS_ENABLE_TESTS=ON \
  -DOpenMVS_ENABLE_IPO=OFF \
  -DENABLE_SSE3=OFF -DENABLE_SSSE3=OFF -DENABLE_SSE41=OFF -DENABLE_SSE42=OFF \
  -DENABLE_AVX=OFF -DENABLE_AVX2=OFF
cmake --build build --parallel ${CPU_COUNT}

# Unit tests (the pipeline test needs downloaded data)
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ]]; then
  # the build-tree binary has no RPATH to $PREFIX/lib (libomp etc.)
  DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib LD_LIBRARY_PATH=$PREFIX/lib build/bin/Tests 0
fi

cmake --install build

# Upstream installs the tools into bin/OpenMVS; put them on PATH.
if [[ "${target_platform}" == osx-* ]]; then
  mv $PREFIX/bin/OpenMVS/Viewer.app $PREFIX/lib/OpenMVS/
  cat > $PREFIX/bin/Viewer <<'EOF'
#!/bin/bash
exec "$(dirname "$0")/../lib/OpenMVS/Viewer.app/Contents/MacOS/Viewer" "$@"
EOF
  chmod +x $PREFIX/bin/Viewer
fi
rm -f $PREFIX/bin/OpenMVS/Tests
mv $PREFIX/bin/OpenMVS/* $PREFIX/bin/
rmdir $PREFIX/bin/OpenMVS
# Upstream's CMake config does not find its dependencies and refers to
# unexported targets; do not ship it.
rm -rf $PREFIX/lib/cmake/OpenMVS
