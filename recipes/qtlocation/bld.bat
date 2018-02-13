@echo on
mkdir build
if errorlevel 1 exit /B 1
cd build
if errorlevel 1 exit /B 1

qmake ..\qtlocation.pro
if errorlevel 1 exit /B 1

jom -j%CPU_COUNT%
if errorlevel 1 exit /B 1
jom check
if errorlevel 1 exit /B 1
jom install

:: Try building "examples/" as a test
echo "Building examples to test library install"
mkdir -p examples
if errorlevel 1 exit /B 1
cd examples/
if errorlevel 1 exit /B 1

qmake ..\..\examples\examples.pro
if errorlevel 1 exit /B 1
jom -j%CPU_COUNT%
if errorlevel 1 exit /B 1
jom check
if errorlevel 1 exit /B 1
