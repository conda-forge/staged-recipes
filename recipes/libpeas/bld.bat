@ECHO ON

:: set pkg-config path so that host deps can be found
set "PKG_CONFIG_PATH=%LIBRARY_LIB%\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig"

:: get mixed path (forward slash) form of prefix so host prefix replacement works
set "LIBRARY_PREFIX_M=%LIBRARY_PREFIX:\=/%"

meson.exe setup builddir --wrap-mode=nofallback --buildtype=release --prefix=%LIBRARY_PREFIX_M% --backend=ninja -Dpython3=true -Dintrospection=true -Dvapi=false -Dwidgetry=true -Ddemos=false
if errorlevel 1 exit 1

ninja -v -C builddir -j %CPU_COUNT%
if errorlevel 1 exit 1

ninja -C builddir install -j %CPU_COUNT%
if errorlevel 1 exit 1

del %LIBRARY_PREFIX%\bin\*.pdb

