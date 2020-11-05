set "ONNX_ML=0"
set CONDA_PREFIX=%LIBRARY_PREFIX%
set CMAKE_GENERATOR="Visual Studio 15 2017"
set CMAKE_BUILD_TYPE=Release
set CMAKE_ARGS="-DONNX_USE_PROTOBUF_SHARED_LIBS=ON -DProtobuf_USE_STATIC_LIBS=OFF -DONNX_USE_LITE_PROTO=ON"
set "PYTHON_EXECUTABLE=%PYTHON%"
set "PYTHON_LIBRARIES=%LIBRARY_LIB%"
set USE_MSVC_STATIC_RUNTIME=0
cmake .. -DCMAKE_INSTALL_PREFIX=%PREFIX%
if errorlevel 1 exit 1
cmake --build .
if errorlevel 1 exit 1
cmake --build . --target install
if errorlevel 1 exit 1

