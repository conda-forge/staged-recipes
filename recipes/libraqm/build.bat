@echo on

:: manually add MESON_ARGS until https://github.com/conda-forge/vc-feedstock/pull/119
meson setup builddir ^
    --backend=ninja ^
    --pkg-config-path="%LIBRARY_LIB%\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig" ^
    --prefix=%LIBRARY_PREFIX% ^
    -Dbuildtype=release ^
    -Dlibdir=lib
if %ERRORLEVEL% neq 0 exit 1

meson compile -v -C builddir
if %ERRORLEVEL% neq 0 exit 1

meson test -C builddir --print-errorlog
if %ERRORLEVEL% neq 0 exit 1

meson install -C builddir
if %ERRORLEVEL% neq 0 exit 1
