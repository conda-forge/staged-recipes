:: Build tcplotter command-line utilities using cmake

:: Change working directory to archive directory
cd "%PKG_NAME%"

:: Create build directory
cd "src"
mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

:: Build with cmake
cmake -G "MinGW Makefiles" ..
if errorlevel 1 exit 1
cmake --build -DCMAKE_CXX_STANDARD=11 .
if errorlevel 1 exit 1

:: Install executables to bin directory
cmake --build . --target install --prefix=%PREFIX%
if errorlevel 1 exit 1

:: Install tcplotter
cd "%SRC_DIR%"
$PYTHON -m pip install . -vv