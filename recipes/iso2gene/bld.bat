@echo on

cmake -S "%SRC_DIR%" -B build -G Ninja %CMAKE_ARGS% ^
  -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit /b 1

cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit /b 1

if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"
copy /Y build\iso2gene.exe "%LIBRARY_BIN%\iso2gene.exe"
if errorlevel 1 exit /b 1

set "DOC_DIR=%LIBRARY_PREFIX%\share\doc\iso2gene"
if not exist "%DOC_DIR%" mkdir "%DOC_DIR%"
copy /Y "%SRC_DIR%\LICENSE" "%DOC_DIR%\LICENSE"
if errorlevel 1 exit /b 1
copy /Y "%SRC_DIR%\README.md" "%DOC_DIR%\README.md"
if errorlevel 1 exit /b 1
copy /Y "%SRC_DIR%\THIRD_PARTY_NOTICES.txt" "%DOC_DIR%\THIRD_PARTY_NOTICES.txt"
if errorlevel 1 exit /b 1
xcopy /E /I /Y "%SRC_DIR%\LICENSES" "%DOC_DIR%\LICENSES"
if errorlevel 1 exit /b 1
