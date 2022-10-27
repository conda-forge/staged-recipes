set -e


cd test
cmake . -G "Ninja" -D CMAKE_BUILD_TYPE="Release"
cmake --build . --config Release
./hello_hpx
