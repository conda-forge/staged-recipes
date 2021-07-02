@REM Configure the build of phreeqc4rkt
cmake -S . -B build ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DBUILD_SHARED_LIBS=ON ^
    -DYAML_BUILD_SHARED_LIBS=ON ^
    -DYAML_CPP_BUILD_TESTS=OFF


@REM Build and install phreeqc4rkt in %LIBRARY_PREFIX%
@REM Note: No need for --parallel below, since cmake takes care of the /MP flag for MSVC
cmake --build build --config Release --target install
