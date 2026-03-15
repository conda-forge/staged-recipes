@echo on
set "PATH=%SRC_DIR%\build;%SRC_DIR%\build\bin;%SRC_DIR%\build\Release;%PATH%"

@REM Test code is not written for Windows
cmake -S . -B build -G "NMake Makefiles JOM" ^
    %CMAKE_ARGS% ^
    -DCMAKE_CXX_FLAGS="%CXXFLAGS% -DUNICODE -D_UNICODE" ^
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
    -DBUILD_SHARED_LIBS=ON
if errorlevel 1 exit 1

cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit 1

ctest -V --test-dir build
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1
