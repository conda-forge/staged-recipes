#!/bin/bash

declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*darwin.* ]]; then
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
else
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
fi

cat > "$SRC_DIR/python/setup.cfg" << EOF
[build_ext]
cmake_opts=-DPython3_EXECUTABLE="${PYTHON}" ${CMAKE_PLATFORM_FLAGS[@]}
EOF

python -m pip install --no-deps -v "${SRC_DIR}/python"

BUILD_DIR="${SRC_DIR}/extern/pygsw/build"
cmake -S "${SRC_DIR}/extern/pygsw" -B "${BUILD_DIR}" -DCMAKE_BUILD_TYPE=Release -DPython3_EXECUTABLE="${PYTHON}" ${CMAKE_PLATFORM_FLAGS[@]}
cmake --build "${BUILD_DIR}" --target pygsw_wheel --config Release --parallel ${CPU_COUNT}
cp -rv "${BUILD_DIR}/pygsw" "${SP_DIR}/pygetm/pygsw"

BUILD_DIR="${SRC_DIR}/extern/python-otps2/build"
cmake -S "${SRC_DIR}/extern/python-otps2" -B "${BUILD_DIR}" -DCMAKE_BUILD_TYPE=Release -DPython3_EXECUTABLE="${PYTHON}" ${CMAKE_PLATFORM_FLAGS[@]}
cmake --build "${BUILD_DIR}" --target otps2_wheel --config Release --parallel ${CPU_COUNT}
cp -rv "${BUILD_DIR}/otps2" "${SP_DIR}/pygetm/otps2"
