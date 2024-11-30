@echo ON

meson setup build %MESON_ARGS%
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

meson compile -C build -j %CPU_COUNT%
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

meson install -C build
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
