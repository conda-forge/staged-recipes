@echo on
setlocal EnableDelayedExpansion

:: CMake does not like paths with \ characters
set LIBRARY_PREFIX=%LIBRARY_PREFIX:\=/%

:: Remove any libgoogle-cloud- prefix and any -devel suffix from PKG_NAME to
:: find the feature name.
set FEATURE=%PKG_NAME:libgoogle-cloud-=%
set FEATURE=%FEATURE:-devel=%

cmake -GNinja ^
    -S "google/cloud/%FEATURE%/quickstart" -B build ^
    -DCMAKE_CXX_STANDARD=17 ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_MODULE_PATH="%LIBRARY_PREFIX%/lib/cmake"
if %ERRORLEVEL% neq 0 exit 1

cmake --build build --config Release
if %ERRORLEVEL% neq 0 exit 1
