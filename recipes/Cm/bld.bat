:: set pkg-config path so that host deps can be found
:: (set as env var so it's used by both meson and during build with g-ir-scanner)
set "PKG_CONFIG_PATH=%LIBRARY_LIB%\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig;%BUILD_PREFIX%\Library\lib\pkgconfig"

mkdir forgebuild
cd forgebuild

%BUILD_PREFIX%\Scripts\meson --buildtype=release --prefix=%LIBRARY_PREFIX% --backend=ninja -Dtests=false ..
if errorlevel 1 exit 1

ninja -v
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
