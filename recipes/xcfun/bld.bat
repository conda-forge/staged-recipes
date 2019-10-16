:: configure
set CMAKE_FLAGS=-DCMAKE_INSTALL_PREFIX=%PREFIX%
set CMAKE_FLAGS=%CMAKE_FLAGS% -DCMAKE_BUILD_TYPE=Release
set CMAKE_FLAGS=%CMAKE_FLAGS% -DCMAKE_CXX_COMPILER=%CXX%
set CMAKE_FLAGS=%CMAKE_FLAGS% -DCMAKE_C_COMPILER=%CC%
set CMAKE_FLAGS=%CMAKE_FLAGS% -DPYTHON_EXECUTABLE=%PYTHON%
set CMAKE_FLAGS=%CMAKE_FLAGS% -DPYMOD_INSTALL_LIBDIR=%PYMOD_INSTALL_LIBDIR%
set CMAKE_FLAGS=%CMAKE_FLAGS% -DENABLE_PYTHON_INTERFACE=ON

cmake -H%SRC_DIR% -Bbuild -G"Ninja" %CMAKE_FLAGS% 

:: build 
cd build
ninja

:: test
:: The Python interface is tested using pytest directly
ctest -E "python-interface" --output-on-failure --verbose

:: install
ninja install


if errorlevel 1 exit 1