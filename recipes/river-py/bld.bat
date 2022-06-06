cd python
mkdir build\release
cd build\release

cmake -G"NMake Makefiles" ^
  -DCMAKE_BUILD_TYPE:STRING=Release ^
  -DPython3_EXECUTABLE="%PYTHON%" ^
  -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_INSTALL_LIBDIR:STRING=lib ^
  -DRIVER_INSTALL=ON ^
  -DRIVER_BUILD_TESTS=OFF ^
  %CMAKE_ARGS% ^
  ..\..
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1

