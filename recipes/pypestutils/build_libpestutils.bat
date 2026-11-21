@echo on

:: configure
:: meson.build rejects optimization=3, which --buildtype=release sets
meson setup builddir %MESON_ARGS% -Doptimization=2 -Ddebug=false

:: build
meson compile -C builddir
if errorlevel 1 exit 1

:: test?

:: install
meson install -C builddir --destdir "%LIBRARY_PREFIX%"
if errorlevel 1 exit 1
