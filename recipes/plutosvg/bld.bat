@echo ON

:: set pkg-config path so that host deps can be found
:: set "PKG_CONFIG_PATH=%LIBRARY_LIB%\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig;%BUILD_PREFIX%\Library\lib\pkgconfig"

meson setup build ^
    %MESON_ARGS% ^
    --prefix="%LIBRARY_PREFIX%" ^
    --buildtype=release ^
    -Dfreetype=enabled ^
    -Dexamples=disabled ^
    -Dtests=disabled
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

meson compile -C build -j %CPU_COUNT%
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%

meson install -C build
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
