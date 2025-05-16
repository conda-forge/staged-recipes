export CMAKE_ARGS="-DCMAKE_POLICY_VERSION_MINIMUM=3.5 $CMAKE_ARGS"

cmake -S . -B build $CMAKE_ARGS
cmake --build build
cmake --install build
