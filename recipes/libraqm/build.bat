@echo on

:: manually add MESON_ARGS until https://github.com/conda-forge/vc-feedstock/pull/119
meson setup builddir ^
    --backend=ninja ^
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
