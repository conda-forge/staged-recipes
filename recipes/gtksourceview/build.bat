setlocal EnableDelayedExpansion
@echo on

:: Setup pkg-config paths
:: Prioritize LIBRARY_PREFIX (host dependencies) so meson finds all glib components
set "PKG_CONFIG_PATH=%LIBRARY_PREFIX%\lib\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig;%BUILD_PREFIX%\Library\lib\pkgconfig"
set "XDG_DATA_DIRS=%XDG_DATA_DIRS%;%LIBRARY_PREFIX%\share"

set "MESON_OPTIONS=--prefix=%LIBRARY_PREFIX% --default-library=shared --wrap-mode=nofallback"
set "MESON_OPTIONS=%MESON_OPTIONS% -Dintrospection=enabled"
set "MESON_OPTIONS=%MESON_OPTIONS% -Dvapi=false"

meson setup %MESON_OPTIONS% builddir
if errorlevel 1 exit 1

ninja -v -C builddir -j %CPU_COUNT%
if errorlevel 1 exit 1

ninja -C builddir install -j %CPU_COUNT%
if errorlevel 1 exit 1
