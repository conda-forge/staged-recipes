@echo ON

cmake -G Ninja -B build ^
    %CMAKE_ARGS% ^
    -D BUILD_SHARED_LIBS=ON ^
    -D PYTHON_EXECUTABLE=%PYTHON% ^
    -D BUILD_PYTHON_WRAPPER=ON ^
    -D BUILD_TESTING=ON
cmake --build build --target install --config Release

cmake -E copy build/apriltag.dll build/test/
ctest --no-tests=error --output-on-failure --verbose --test-dir build/test/
