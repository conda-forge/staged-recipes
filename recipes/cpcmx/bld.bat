setlocal EnableExtensions EnableDelayedExpansion
@echo on

set "PKG_CONFIG_PATH=%LIBRARY_LIB%\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig;%BUILD_PREFIX%\Library\lib\pkgconfig"
set "MESON_RSP_THRESHOLD=320000"

meson setup _build -Dprefix=%LIBRARY_PREFIX% -Dbuildtype=release -Ddefault_library=shared -Dlapack=custom
if %ERRORLEVEL% neq 0 exit 1

meson compile -C _build
if %ERRORLEVEL% neq 0 exit 1

meson test -C _build --no-rebuild --print-errorlogs
if %ERRORLEVEL% neq 0 exit 1

meson install -C _build --no-rebuild
if %ERRORLEVEL% neq 0 exit 1
