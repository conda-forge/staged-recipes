@ECHO ON

:: set pkg-config path so that host deps can be found
:: (set as env var so it's used by meson)
set "PKG_CONFIG_PATH=%LIBRARY_LIB%\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig;%BUILD_PREFIX%\Library\lib\pkgconfig"

:: get mixed path (forward slash) form of prefix so host prefix replacement works
set "LIBRARY_PREFIX_M=%LIBRARY_PREFIX:\=/%"

%BUILD_PREFIX%\Scripts\meson.exe setup builddir --buildtype=release --prefix=%LIBRARY_PREFIX_M% --backend=ninja %MESON_ARGS%
if errorlevel 1 exit 1

ninja -v -C builddir -j %CPU_COUNT%
if errorlevel 1 exit 1

ninja -C builddir install -j %CPU_COUNT%
if errorlevel 1 exit 1

rmdir /s /q %LIBRARY_PREFIX%\share\man
