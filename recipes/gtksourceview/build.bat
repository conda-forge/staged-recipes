setlocal EnableDelayedExpansion
@echo on

meson setup --prefix=%LIBRARY_PREFIX% --default-library=shared --wrap-mode=nofallback --buildtype=release -Dintrospection=enabled -Ddocumentation=false -Dvapi=false builddir
if errorlevel 1 exit 1

ninja -v -C builddir -j %CPU_COUNT%
if errorlevel 1 exit 1

ninja -C builddir install -j %CPU_COUNT%
if errorlevel 1 exit 1
