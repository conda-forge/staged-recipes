meson setup builddir --prefix=%LIBRARY_PREFIX% --buildtype=release -Denable_tests=false
if errorlevel 1 exit 1
meson compile -C builddir
if errorlevel 1 exit 1
meson install -C builddir
if errorlevel 1 exit 1
