setlocal EnableExtensions EnableDelayedExpansion
@echo on

meson setup _build --prefix=%LIBRARY_PREFIX%
if errorlevel 1 exit 1

meson compile -C _build
if errorlevel 1 exit 1

meson test -C _build --no-rebuild --print-errorlogs
if errorlevel 1 exit 1

meson install -C _build --no-rebuild
if errorlevel 1 exit 1
