setlocal EnableDelayedExpansion

set "CPPFLAGS=%CPPFLAGS% -I%LIBRARY_INC%"
set "CXXFLAGS=%CXXFLAGS% -I%LIBRARY_INC%"

REM MESON_ARGS already provides prefix and libdir; do not pass them again.
meson setup builddir %MESON_ARGS% -Ddefault_library=shared -Dbuild_tests=false -Dbuild_exe=false -Dwith_netcdf=true -Dbuild_shared_lib=true
if errorlevel 1 exit 1
meson compile -C builddir -j %CPU_COUNT%
if errorlevel 1 exit 1
meson install -C builddir
if errorlevel 1 exit 1

mkdir "%LIBRARY_INC%"
xcopy /E /I /Y flowy "%LIBRARY_INC%\flowy"
if errorlevel 1 exit 1

mkdir "%LIBRARY_LIB%\pkgconfig"
(
echo prefix=%LIBRARY_PREFIX%
echo libdir=${prefix}/lib
echo includedir=${prefix}/include
echo Name: flowy
echo Description: Probabilistic lava emplacement library
echo Version: 1.0.0
echo Requires: pdf_cpplib fmt
echo Libs: -L${libdir} -lflowy
echo Cflags: -I${includedir}
) > "%LIBRARY_LIB%\pkgconfig\flowy.pc"
