setlocal EnableDelayedExpansion

:: Make a build folder and change to it.
mkdir build
cd build

:: Configure using the CMakeFiles
cmake -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" -DCMAKE_BUILD_TYPE=Release -DCPP_TARGETS=cpp ..
if errorlevel 1 exit 1

:: Build!
nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1