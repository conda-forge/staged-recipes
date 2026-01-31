set -euxo pipefail
cmake -B${CMAKE_ARGS} \
  -B build \
  -DCMAKE_PREFIX_PATH:PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  .

cmake --build build
cmake --install build
