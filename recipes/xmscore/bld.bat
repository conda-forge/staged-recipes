if not exist "build\" mkdir build
cd build
%LIBRARY_PREFIX%\bin\cmake.exe -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=True -DIS_CONDA_BUILD=True ..
nmake -f Makefile
nmake install -f Makefile