setlocal EnableDelayedExpansion
@echo on

set "PKG_CONFIG_PATH=%LIBRARY_PREFIX%\lib\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig;%BUILD_PREFIX%\Library\lib\pkgconfig"
set "XDG_DATA_DIRS=%XDG_DATA_DIRS%;%LIBRARY_PREFIX%\share"

meson setup --prefix=%LIBRARY_PREFIX% --default-library=shared --wrap-mode=nofallback -Dintrospection=enabled -Dvapi=false builddir
if errorlevel 1 exit 1

ninja -v -C builddir -j %CPU_COUNT%
if errorlevel 1 exit 1

ninja -C builddir install -j %CPU_COUNT%
if errorlevel 1 exit 1
