setlocal EnableDelayedExpansion

:: Make a build folder and change to it
mkdir build
cd build

:: configure
cmake -G "NMake Makefiles JOM" ^
      -DBoost_NO_BOOST_CMAKE=ON ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -DPYTHON_EXECUTABLE:PATH="%PYTHON%" ^
      -DVOLK_PYTHON_DIR:PATH="%PREFIX%"\Lib\site-packages ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      -DENABLE_ORC:BOOL=OFF ^
      -DENABLE_PROFILING:BOOL=OFF ^
      -DENABLE_TESTING:BOOL=ON ^
      ..
if errorlevel 1 exit 1

:: build
cmake --build . -- -j%CPU_COUNT%
if errorlevel 1 exit 1

:: test
ctest --output-on-failure
::if errorlevel 1 exit 1

:: install
cmake --build . --target install
if errorlevel 1 exit 1
