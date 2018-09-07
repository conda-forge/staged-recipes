:: Prep build
xcopy "%LIBRARY_LIB%\cmake\llvm" "%LIBRARY_LIB%\cmake\modules\" /s /h /e /k /f /c
if errorlevel 1 exit 1

mkdir build
if errorlevel 1 exit 1

cd build
if errorlevel 1 exit 1

set BUILD_CONFIG=Release
if errorlevel 1 exit 1

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH="%LIBRARY_BIN%" ^
    -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH="%LIBRARY_LIB%" ^
    -DCMAKE_MODULE_PATH:PATH="%LIBRARY_LIB%\cmake" ^
    -DCMAKE_C_COMPILER:PATH="%LIBRARY_BIN%\clang-cl.exe" ^
    -DCMAKE_CXX_COMPILER:PATH="%LIBRARY_BIN%\clang-cl.exe" ^
    -DLLVM_CONFIG_PATH:PATH="%LIBRARY_BIN%\llvm-config.exe" ^
    "%SRC_DIR%"
if errorlevel 1 exit 1

:: Build step
nmake
if errorlevel 1 exit 1

:: Install step
nmake install
if errorlevel 1 exit 1

:: Clean up after build
rmdir "%LIBRARY_LIB%\cmake\modules" /s /q
if errorlevel 1 exit 1
