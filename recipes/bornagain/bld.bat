mkdir build
cd build
cmake ^
    -G "Ninja" ^
    -D Python_ADDITIONAL_VERSIONS=${PY_VER} ^
    -D PYTHON_EXECUTABLE="%PYTHON%" ^
    -D PYTHON_INCLUDE_DIR="%PREFIX%\include" ^
    -D PYTHON_LIBRARY="%PREFIX%\libs\python%CONDA_PY%.lib" ^
    -D PYTHON_INSTDIR="%SP_DIR%" ^
    -D BOOST_ROOT="%LIBRARY_PREFIX%" ^
    -D Boost_NO_SYSTEM_PATHS=ON ^
    -D Boost_NO_BOOST_CMAKE=ON ^
    -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -D CMAKE_BUILD_TYPE=Release ^
    ..
if errorlevel 1 (
    type %SRC_DIR%\build\MakeFiles\CMakeOutput.log
    type %SRC_DIR%\build\MakeFiles\CMakeError.log
    exit 1
)

ninja
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
