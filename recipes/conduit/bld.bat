setlocal EnableDelayedExpansion

:: Make a build folder and change to it.
mkdir build
cd build

:: Configure using the CMakeFiles
cmake -G "NMake Makefiles" ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      -DENABLE_PYTHON=ON ^
      -DPYTHON_EXECUTABLE:FILEPATH="%PYTHON%" ^
      -DPYTHON_MODULE_INSTALL_PREFIX="%SP_DIR%" ^
      -DHDF5_DIR:PATH="%LIBRARY_PREFIX%" ^
      ../src
:: if errorlevel 1 exit 1

:: Build!
nmake VERBOSE=1
if errorlevel 1 exit 1

:: Install!
nmake install
if errorlevel 1 exit 1

:: Triumph !