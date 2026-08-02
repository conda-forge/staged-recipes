mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DSPIRV_CROSS_SHARED=ON ^
    -DSPIRV_CROSS_ENABLE_TESTS=OFF ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: The CLI requires the static targets at build time. Remove their installed
:: artifacts while retaining the shared C API import library.
for %%F in (%LIBRARY_LIB%\spirv-cross-*.lib) do (
    if /I not "%%~nxF"=="spirv-cross-c-shared.lib" del "%%F"
)
