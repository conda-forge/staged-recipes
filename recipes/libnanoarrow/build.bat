@echo on

meson setup builddir %MESON_ARGS% ^
    --backend=ninja ^
    -Ddefault_library=shared ^
    -Dtests=enabled
if %ERRORLEVEL% neq 0 exit 1

meson compile -v -C builddir
if %ERRORLEVEL% neq 0 exit 1

meson test -C builddir --print-errorlog
if %ERRORLEVEL% neq 0 exit 1

meson install -C builddir
if %ERRORLEVEL% neq 0 exit 1
