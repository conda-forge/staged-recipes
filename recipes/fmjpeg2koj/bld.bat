mkdir build
cd build


cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -DFMJPEG2K=%LIBRARY_PREFIX% ..

if errorlevel 1 exit 1

cmake --build . --config Release --target install --parallel
if errorlevel 1 exit 1
