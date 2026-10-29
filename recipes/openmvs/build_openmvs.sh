#!/bin/bash
set -euxo pipefail

# OpenMVS loads vcpkg's toolchain whenever VCPKG_ROOT is set.
unset VCPKG_ROOT

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
  -DINSTALL_USE_SUBDIR=OFF \
  -DOpenMVS_LIBRARY_NAME_PREFIX=OpenMVS \
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

# Unit tests (the pipeline test needs downloaded data). CUDA builds link the
# CUDA driver (libcuda.so.1), so they only run where one is installed.
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ]] && \
   { [[ "${cuda_compiler_version:-None}" == "None" ]] || ( /sbin/ldconfig -p 2>/dev/null || true ) | grep -q "libcuda.so.1"; }; then
  # the build-tree binary has no RPATH to $PREFIX/lib (libomp etc.)
  DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib LD_LIBRARY_PATH=$PREFIX/lib build/bin/Tests 0
fi

cmake --install build

# macOS: the Viewer is an app bundle (bin/Viewer.app, as exported in the CMake
# package); add a launcher next to it so `Viewer` works like the other tools.
if [[ "${target_platform}" == osx-* ]]; then
  cat > $PREFIX/bin/Viewer <<'LAUNCHER'
#!/bin/bash
exec "$(dirname "$0")/Viewer.app/Contents/MacOS/Viewer" "$@"
LAUNCHER
  chmod +x $PREFIX/bin/Viewer
fi
rm -f $PREFIX/bin/Tests
