meson setup builddir ^
  --prefix="%LIBRARY_PREFIX%" ^
  --buildtype=release ^
  --wrap-mode=nofallback
if errorlevel 1 exit /b 1

meson compile -C builddir
if errorlevel 1 exit /b 1

meson install -C builddir
if errorlevel 1 exit /b 1