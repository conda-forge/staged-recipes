@echo on
setlocal EnableDelayedExpansion

:: CMake does not like paths with \ characters
set LIBRARY_PREFIX=%LIBRARY_PREFIX:\=/%

cmake -G "Ninja" ^
    -S . -B build ^
    -DGOOGLE_CLOUD_CPP_ENABLE=bigquery ^
    -DGOOGLE_CLOUD_CPP_USE_INSTALLED_COMMON=ON ^
    -DBUILD_TESTING=OFF ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_CXX_STANDARD=17 ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_MODULE_PATH="%LIBRARY_PREFIX%/lib/cmake" ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    -DGOOGLE_CLOUD_CPP_ENABLE_EXAMPLES=OFF ^
    -DGOOGLE_CLOUD_CPP_ENABLE_WERROR=OFF
if %ERRORLEVEL% neq 0 exit 1

cmake --build build --config Release
if %ERRORLEVEL% neq 0 exit 1
