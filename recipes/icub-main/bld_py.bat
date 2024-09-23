cd bindings
rmdir /s /q build
mkdir build
cd build

cmake %CMAKE_ARGS% -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DPython_EXECUTABLE:PATH=%PYTHON% ^
    -DCREATE_PYTHON:BOOL=ON ^
    -DCREATE_RUBY:BOOL=OFF ^
    -DCREATE_JAVA:BOOL=ON ^
    -DCREATE_CSHARP:BOOL=ON ^
    -DDCMAKE_INSTALL_PYTHONDIR:PATH=%SP_DIR% ^
    ..
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
