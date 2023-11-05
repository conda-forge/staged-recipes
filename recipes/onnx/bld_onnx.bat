@echo on

REM Copy over our python only cmake script
REM it is mostly just the original cmake script with everything not
REM related to python deleted
REM I can't get this to work, so technically we will be building the same package multiple times
REM copy %RECIPE_DIR%\CMakeLists_python_only.txt CMakeLists.txt

set "ONNX_ML=1"
set CONDA_PREFIX=%LIBRARY_PREFIX%
set CMAKE_BUILD_TYPE=Release

set "CMAKE_ARGS=%CMAKE_ARGS% -DONNX_USE_PROTOBUF_SHARED_LIBS=ON -DProtobuf_USE_STATIC_LIBS=OFF -DONNX_USE_LITE_PROTO=ON -DCMAKE_CXX_FLAGS="""/DPROTOBUF_USE_DLLS=1 /EHsc /std:c++17""""
set "PYTHON_EXECUTABLE=%PYTHON%"
set "PYTHON_LIBRARIES=%LIBRARY_LIB%"
set USE_MSVC_STATIC_RUNTIME=0
%PYTHON% -m pip install --no-deps --no-use-pep517 --ignore-installed --verbose .
