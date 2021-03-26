setlocal EnableDelayedExpansion
@echo on

:: set pkg-config path so that host deps can be found
:: (set as env var so it's used by both meson and during build with g-ir-scanner)
set "PKG_CONFIG_PATH=%LIBRARY_LIB%\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig;%BUILD_PREFIX%\Library\lib\pkgconfig"

set "XDG_DATA_DIRS=%XDG_DATA_DIRS%;%LIBRARY_PREFIX%\share"

:: ensure that the post install script is ignored
set "DESTDIR=%BUILD_PREFIX:~0,3%"

:: meson options
:: (set pkg_config_path so deps in host env can be found)
set ^"MESON_OPTIONS=^
  --prefix="%LIBRARY_PREFIX%" ^
  --default-library=shared ^
  --wrap-mode=nofallback ^
  --force-fallback-for=sassc,libsass ^
  --buildtype=release ^
  --backend=ninja ^
  -Dgtk_doc=false ^
  -Dman-pages=false ^
  -Dintrospection=enabled ^
  -Dbuild-examples=false ^
  -Dbuild-tests=false ^
 ^"

:: configure build using meson
meson setup builddir !MESON_OPTIONS!
if errorlevel 1 exit 1

:: print results of build configuration
meson configure builddir
if errorlevel 1 exit 1

ninja -v -C builddir -j %CPU_COUNT%
if errorlevel 1 exit 1

ninja -C builddir install -j %CPU_COUNT%
if errorlevel 1 exit 1

:: cleanup sassc files
del %LIBRARY_BIN%\sass.dll
del %LIBRARY_BIN%\sassc.exe
del %LIBRARY_LIB%\sass.lib
del %LIBRARY_LIB%\pkgconfig\libsass.pc
del /s /q %LIBRARY_INC%\sass*
rmdir /s /q %LIBRARY_INC%\sass
