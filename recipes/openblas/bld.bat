:: Setup a build directory.
mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

:: Configure, build, test, and install using `nmake`.
cmake -G "NMake Makefiles" ^
         -DCMAKE_BUILD_TYPE=Release ^
         -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
         -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
         -DQUIET_MAKE=ON ^
         -DDYNAMIC_ARCH=ON ^
         -DBUILD_WITHOUT_LAPACK=OFF ^
         -DSMP=ON ^
         ..
if errorlevel 1 exit 1
nmake
if errorlevel 1 exit 1
nmake check
if errorlevel 1 exit 1
nmake install
if errorlevel 1 exit 1
