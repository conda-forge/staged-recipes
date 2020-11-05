set "ONNX_ML=0"
set CONDA_PREFIX=%LIBRARY_PREFIX%
set "PYTHON_EXECUTABLE=%PYTHON%"
set "PYTHON_LIBRARIES=%LIBRARY_LIB%"
mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1
cmake .. -DCMAKE_INSTALL_PREFIX=%PREFIX% -DONNX_USE_PROTOBUF_SHARED_LIBS=ON -DProtobuf_USE_STATIC_LIBS=OFF -DONNX_USE_LITE_PROTO=ON -DCMAKE_BUILD_TYPE=Release
if errorlevel 1 exit 1
cmake --build .
if errorlevel 1 exit 1
cmake --build . --target install
if errorlevel 1 exit 1

