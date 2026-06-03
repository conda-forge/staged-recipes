@echo on

set LIB=%SRC_DIR%\build;%LIB%

@REM Fix VLA for MSVC: use WIDTH (=255) instead of variable numColorsLocal as array size
sed -i -e "s|\[3\*numColorsLocal\]|[3*WIDTH]|g" tests\more_than_256_colors.c
if %ERRORLEVEL% neq 0 exit /b 1

@REM Remove GCC/Clang-specific `__attribute__` not supported by MSVC
sed -i "/__attribute__/d" ^
  tests\noise256.c ^
  tests\noise256_large.c ^
  tests\noise6.c ^
  tests\noise6_interlaced.c
if %ERRORLEVEL% neq 0 exit /b 1

@REM Remove soversion and version to fix DLL naming on MSVC (cgif-0.dll -> cgif.dll)
sed -i -e "/soversion/d" -e "/version : meson/d" meson.build
if %ERRORLEVEL% neq 0 exit /b 1

@REM Write a native file to append link args without overwriting MESON_ARGS
echo [built-in options] > %SRC_DIR%\msvc_export.ini
echo c_link_args = ['/EXPORT:cgif_newgif', '/EXPORT:cgif_addframe', '/EXPORT:cgif_close', '/EXPORT:cgif_rgb_newgif', '/EXPORT:cgif_rgb_addframe', '/EXPORT:cgif_rgb_close'] >> %SRC_DIR%\msvc_export.ini

meson setup build %MESON_ARGS% ^
    --native-file %SRC_DIR%\msvc_export.ini ^
    -Dtests=true ^
    -Dexamples=true ^
    -Dinstall_examples=false
if %ERRORLEVEL% neq 0 exit /b 1

meson compile -C build -j %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit /b 1

meson test -C build --num-processes %CPU_COUNT% --print-errorlogs
if %ERRORLEVEL% neq 0 exit /b 1

meson install -C build
if %ERRORLEVEL% neq 0 exit /b 1
