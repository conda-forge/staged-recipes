setlocal EnableDelayedExpansion
@echo on

:: runSofa application
rmdir /S /Q build-sofa-app

mkdir build-sofa-app
cd build-sofa-app

:: Configure
cmake %CMAKE_ARGS% ^
  -B . ^
  -S %SRC_DIR%\applications\projects\runSofa ^
  -G Ninja ^
  -DCMAKE_BUILD_TYPE:STRING=Release
if errorlevel 1 exit 1

:: Build.
cmake --build . --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1

:: Install.
cmake --build . --parallel "%CPU_COUNT%" --target install
if errorlevel 1 exit 1

cd ..

:: runSofa app requires some data ressources, which will
:: be included in this package
rmdir /S /Q build-sofa-examples

mkdir build-sofa-examples
cd build-sofa-examples

:: Configure
cmake %CMAKE_ARGS% ^
  -B . ^
  -S %SRC_DIR%\examples ^
  -G Ninja ^
  -DCMAKE_BUILD_TYPE:STRING=Release
if errorlevel 1 exit 1

:: Build.
cmake --build . --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1

:: Install.
cmake --build . --parallel "%CPU_COUNT%" --target install
if errorlevel 1 exit 1
