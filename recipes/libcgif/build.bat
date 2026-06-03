@echo on

@REM Fix VLA for MSVC: use WIDTH (=255) instead of variable numColorsLocal as array size
sed -i -e "s|\[3\*numColorsLocal\]|[3*WIDTH]|g" tests\more_than_256_colors.c

@REM Remove GCC/Clang-specific `__attribute__` not supported by MSVC
sed -i "|__attribute__|d" ^
  tests\noise256.c ^
  tests\noise256_large.c ^
  tests\noise6.c ^
  tests\noise6_interlaced.c

meson setup build %MESON_ARGS% ^
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
