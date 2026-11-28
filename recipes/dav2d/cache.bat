@echo on

meson setup builddir           ^
    %MESON_ARGS%               ^
    --prefix=%LIBRARY_PREFIX%  ^
    -Denable_tests=false       ^
    --buildtype=release
if errorlevel 1 exit 1

meson compile -C builddir
if errorlevel 1 exit 1

meson install -C builddir --no-rebuild
if errorlevel 1 exit 1
