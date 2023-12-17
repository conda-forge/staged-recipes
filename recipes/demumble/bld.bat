@echo on

md build
if %ERRORLEVEL% neq 0 exit 1
pushd build
cmake %CMAKE_ARGS% -GNinja -DCMAKE_CXX_STANDARD=17 ..
if %ERRORLEVEL% neq 0 exit 1
ninja
if %ERRORLEVEL% neq 0 exit 1

if not exist "%LIBRARY_PREFIX%\bin" md "%LIBRARY_PREFIX%\bin"
if %ERRORLEVEL% neq 0 exit 1

cp demumble.exe %LIBRARY_PREFIX%\bin
if %ERRORLEVEL% neq 0 exit 1

