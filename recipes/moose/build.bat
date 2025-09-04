@echo on
setlocal enabledelayedexpansion

REM Configure
meson setup builddir ^
  --prefix=%PREFIX% ^
  --buildtype=release ^
  -Dpython=true

REM Build
meson compile -C builddir

REM Install
meson install -C builddir

