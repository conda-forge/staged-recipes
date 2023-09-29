mkdir build
cd build
cmake ^
    -G "Visual Studio 15 2017" ^
    -DCMAKE_GENERATOR_PLATFORM=x64 ^
    -DCMAKE_CXX_STANDARD=17 ^
    -DCMAKE_BUILD_TYPE=RELEASE ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DSPICEQL_BUILD_DOCS=OFF ^
    -DSPICEQL_BUILD_TESTS=OFF ^
    -DPython3_EXECUTABLE=$PYTHON ^
    ..
cmake --build . --config RELEASE
cmake --install . --config RELEASE
if errorlevel 1 exit 1
