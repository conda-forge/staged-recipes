mkdir build
cd build


cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_CXX_FLAGS_RELEASE="/MT /O2 /D NDEBUG" -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -DFMJPEG2K=%LIBRARY_PREFIX% ..

if errorlevel 1 exit 1

cmake --build . --config Release --target install --parallel
if errorlevel 1 exit 1
