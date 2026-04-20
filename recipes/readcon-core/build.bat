cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1

cargo auditable build --release --locked
if errorlevel 1 exit 1

if defined CARGO_BUILD_TARGET (
    set "RELEASE_DIR=target\%CARGO_BUILD_TARGET%\release"
) else (
    set "RELEASE_DIR=target\release"
)

mkdir %LIBRARY_BIN%
copy "%RELEASE_DIR%\readcon_core.dll" %LIBRARY_BIN%\
if errorlevel 1 exit 1

mkdir %LIBRARY_LIB%
copy "%RELEASE_DIR%\readcon_core.dll.lib" %LIBRARY_LIB%\
if errorlevel 1 exit 1

mkdir %LIBRARY_INC%
copy include\readcon-core.h %LIBRARY_INC%\
copy include\readcon-core.hpp %LIBRARY_INC%\
if errorlevel 1 exit 1

mkdir %LIBRARY_LIB%\pkgconfig
(
echo prefix=${pcfiledir}/../..
echo libdir=${prefix}/lib
echo includedir=${prefix}/include
echo.
echo Name: readcon-core
echo Description: CON file reader/writer in Rust with C FFI bindings
echo Version: %PKG_VERSION%
echo Libs: -L${libdir} -lreadcon_core
echo Cflags: -I${includedir}
) > %LIBRARY_LIB%\pkgconfig\readcon-core.pc
if errorlevel 1 exit 1
