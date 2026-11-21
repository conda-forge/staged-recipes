@echo on

:: temporary prefix to be able to install files more granularly
mkdir temp_prefix

if "%PKG_NAME%" == "libbolt-devel" (
    cmake --install ./build --prefix=./temp_prefix
    if %ERRORLEVEL% neq 0 exit 1
    REM only bolt libraries
    move .\temp_prefix\lib\LLVMBOLT*.lib %LIBRARY_LIB%
    REM copy CMake metadata
    move .\temp_prefix\lib\cmake\llvm %LIBRARY_LIB%\cmake\llvm
    REM unclear which headers belong to bolt, but if some are there, install
    move .\temp_prefix\include %LIBRARY_INC%
) else (
    REM bolt: everything else
    cmake --install .\build --prefix=%LIBRARY_PREFIX%
    if %ERRORLEVEL% neq 0 exit 1
)

rmdir /s /q temp_prefix
