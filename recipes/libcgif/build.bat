@echo on

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
