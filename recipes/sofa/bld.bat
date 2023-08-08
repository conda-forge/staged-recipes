setlocal EnableDelayedExpansion

mkdir build
cd build

:: Configure
cmake %CMAKE_ARGS% ^
  -B . ^
  -S %SRC_DIR% ^
  -G Ninja ^
  -DCMAKE_BUILD_TYPE:STRING=Release ^
  -DSOFA_ENABLE_LEGACY_HEADERS:BOOL=OFF ^
  -DSOFA_BUILD_TESTS:BOOL=ON
if errorlevel 1 exit 1

:: Build.
cmake --build . --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1

:: Install.
cmake --build . --parallel "%CPU_COUNT%" --target install
if errorlevel 1 exit 1

:: For Windows build, as we don't have rpath like in Unix systems to store
:: paths to internal Sofa plugins dynamic libraries and as each plugin is stored
:: into a separated folder, we have to copy all plugins libaries into the main 
:: Sofa binary folder. This should change in Sofa in future releases and will enable
:: to avoid this.
for /D %%f in ("%LIBRARY_PREFIX%\plugins\*") do copy "%%f\bin\*.dll" "%LIBRARY_BIN%"

:: Test
ctest --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1