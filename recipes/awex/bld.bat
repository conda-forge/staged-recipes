
set CMAKE_GENERATOR=MinGW Makefiles
set FC=gfortran
set CC=gcc

(
echo [build_ext]
echo cmake_opts=-DPython3_EXECUTABLE="%PYTHON%"
) > "%SRC_DIR%\setup.cfg"

python -m pip install "%SRC_DIR%"
