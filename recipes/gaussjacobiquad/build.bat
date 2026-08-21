@echo on
meson setup build %MESON_ARGS% -Dwarning_level=1
if errorlevel 1 exit /b 1
meson compile -C build -j %CPU_COUNT%
if errorlevel 1 exit /b 1
meson install -C build
if errorlevel 1 exit /b 1
