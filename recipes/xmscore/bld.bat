if not exist "build\" mkdir build
cd build
%BUILD_PREFIX%\bin\cmake -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=True -DIS_CONDA_BUILD=True ..
%BUILD_PREFIX%\bin\cmake --build --target INSTALL --config Release ..