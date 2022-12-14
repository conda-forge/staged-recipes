setlocal EnableDelayedExpansion
@echo on

set ^"MESON_OPTIONS=^
  --prefix="%LIBRARY_PREFIX%" ^
  --wrap-mode=nofallback ^
  --buildtype=release ^
  --backend=ninja ^
  --default-library=shared ^
  -Ddocs=false ^
  -Ddsound=disabled ^
 ^"

meson setup builddir !MESON_OPTIONS!
if errorlevel 1 exit 1

:: print results of build configuration
meson configure builddir
if errorlevel 1 exit 1

ninja -v -C builddir
if errorlevel 1 exit 1

ninja -C builddir install
if errorlevel 1 exit 1
