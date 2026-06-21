setlocal EnableDelayedExpansion
@echo on

:: SceneChecking application

:: Configure
cmake %CMAKE_ARGS% ^
  -B build-scene-checking ^
  -S %SRC_DIR%\applications\projects\SceneChecking ^
  -G Ninja ^
  -DSCENECHECKING_BUILD_TESTS=OFF ^
  -DCMAKE_BUILD_TYPE:STRING=Release
if errorlevel 1 exit 1

:: Build.
cmake --build build-scene-checking --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1

:: Install.
cmake --install build-scene-checking
if errorlevel 1 exit 1

:: runSofa application

:: Configure
cmake %CMAKE_ARGS% ^
  -B build-sofa-app ^
  -S %SRC_DIR%\applications\projects\runSofa ^
  -G Ninja ^
  -DCMAKE_BUILD_TYPE:STRING=Release
if errorlevel 1 exit 1

:: Build.
cmake --build build-sofa-app --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1

:: Install.
cmake --install build-sofa-app
if errorlevel 1 exit 1

:: runSofa app requires some data ressources, which will
:: be included in this package

:: Configure
cmake %CMAKE_ARGS% ^
  -B build-sofa-examples ^
  -S %SRC_DIR%\examples ^
  -G Ninja ^
  -DCMAKE_BUILD_TYPE:STRING=Release
if errorlevel 1 exit 1

:: Build.
cmake --build build-sofa-examples --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1

:: Install.
cmake --install build-sofa-examples
if errorlevel 1 exit 1
