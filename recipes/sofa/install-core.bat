setlocal EnableDelayedExpansion
@echo on

cd build

if [%PKG_NAME%] == [libsofa-core] (
    REM only the libraries (don't copy CMake metadata)
    move temp_prefix\lib\Sofa* %LIBRARY_LIB%
    REM dll's go to LIBRARY_BIN
    move temp_prefix\bin\Sofa*.dll %LIBRARY_BIN%
) else if [%PKG_NAME%] == [libsofa-core-devel] (
    REM headers
    robocopy temp_prefix\include %LIBRARY_INC% /E >nul
    mkdir %LIBRARY_LIB%\cmake
    move temp_prefix\lib\cmake\Sofa* %LIBRARY_LIB%\cmake
) else (
    echo "Invalid package to install"
    exit 1
)