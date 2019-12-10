setlocal EnableDelayedExpansion

:: Make a build folder and change to it
mkdir build
cd build

:: configure
cmake -G "NMake Makefiles" ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -DDRF_DATA_PREFIX_PYTHON:PATH="%LIBRARY_PREFIX%" ^
      -DPython_FIND_REGISTRY=NEVER ^
      -DPython_ROOT_DIR:PATH="%PREFIX%" ^
      ..
if errorlevel 1 exit 1

:: build
cmake --build .
if errorlevel 1 exit 1

:: install
cmake --build . --target install
if errorlevel 1 exit 1
