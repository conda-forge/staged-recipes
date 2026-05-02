setlocal EnableDelayedExpansion

meson setup builddir ^
    --prefix=%LIBRARY_PREFIX% ^
    --libdir=lib ^
    --buildtype=release ^
    --default-library=shared ^
    -Denable_tools=true ^
    -Denable_tests=false ^
    -Denable_examples=false
if errorlevel 1 exit 1

meson compile -C builddir -v
if errorlevel 1 exit 1

meson install -C builddir
if errorlevel 1 exit 1
