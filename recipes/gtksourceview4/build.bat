setlocal EnableDelayedExpansion
@echo on

:: add include dirs to search path
set "INCLUDE=%INCLUDE%;%LIBRARY_INC%\atk-1.0;%LIBRARY_INC%\pango-1.0"

:: set pkg-config path so that host deps can be found
:: (set as env var so it's used by both meson and during build with g-ir-scanner)
:: set "PKG_CONFIG_PATH=%LIBRARY_LIB%\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig"

:: ensure that the post install script is ignored
set "DESTDIR=%BUILD_PREFIX:~0,3%"

:: meson options
:: (set pkg_config_path so deps in host env can be found)
set ^"MESON_OPTIONS=^
  --prefix="%LIBRARY_PREFIX%" ^
  --wrap-mode=nofallback ^
  --buildtype=release ^
  --backend=ninja ^
  -D gtk_doc=false ^
  -D vapi=false ^
  -D gir=true ^
  -D glade_catalog=false ^

)
 ^"

:: configure build using meson
%BUILD_PREFIX%\python.exe %BUILD_PREFIX%\Scripts\meson setup builddir !MESON_OPTIONS!
if errorlevel 1 exit 1

:: print results of build configuration
%BUILD_PREFIX%\python.exe %BUILD_PREFIX%\Scripts\meson configure builddir
if errorlevel 1 exit 1

ninja -v -C builddir -j %CPU_COUNT%
if errorlevel 1 exit 1

ninja -C builddir install -j %CPU_COUNT%
if errorlevel 1 exit 1