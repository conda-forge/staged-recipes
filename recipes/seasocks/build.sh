set -euxo pipefail

cmake ${CMAKE_ARGS} -S . -B build -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DSEASOCKS_SHARED=ON -DUNITTESTS=OFF -DSEASOCKS_EXAMPLE_APP=OFF
cmake --build build --config Release --target install
