 #!/bin/sh

mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=Release .. \
      -DBUILD_TESTS=ON

cmake --build . --config Release
cmake --build . --config Release --target install
ctest --output-on-failure -C Release -E "misc::check_license"
