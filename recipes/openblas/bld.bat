:: Setup a build directory.
mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

:: Configure, build, test, and install using `nmake`.
bash -lc "make"
if errorlevel 1 exit 1
bash -lc "make check"
if errorlevel 1 exit 1
bash -lc "make install"
if errorlevel 1 exit 1
