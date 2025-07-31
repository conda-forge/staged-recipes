@echo off

:: Configure
cmake %CMAKE_ARGS% ^
    -G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
    -S "%SRC_DIR%" ^
    -B build || exit /b 1

:: Build & Install
cmake --build build --target install || exit /b 1
