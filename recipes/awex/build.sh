#!/bin/bash

declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*darwin.* ]]; then
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
else
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
fi

cat > "$SRC_DIR/setup.cfg" << EOF
[build_ext]
cmake_opts=-DPython3_EXECUTABLE="${PYTHON}" ${CMAKE_PLATFORM_FLAGS[@]}
EOF

python -m pip install "${SRC_DIR}"
