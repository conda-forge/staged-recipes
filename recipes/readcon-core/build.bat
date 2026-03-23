cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1

cargo build --release
if errorlevel 1 exit 1

if defined CARGO_BUILD_TARGET (
    set "RELEASE_DIR=target\%CARGO_BUILD_TARGET%\release"
) else (
    set "RELEASE_DIR=target\release"
)

mkdir %LIBRARY_LIB%
copy "%RELEASE_DIR%\readcon_core.lib" %LIBRARY_LIB%\
if errorlevel 1 exit 1

mkdir %LIBRARY_INC%
copy include\readcon-core.h %LIBRARY_INC%\
copy include\readcon-core.hpp %LIBRARY_INC%\
if errorlevel 1 exit 1
