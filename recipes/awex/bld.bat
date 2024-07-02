
(
echo [build_ext]
echo cmake_opts=-DPython3_EXECUTABLE="%PYTHON%" -DCMAKE_Fortran_COMPILER=gfortran -DCMAKE_C_COMPILER=gcc -G "MinGW Makefiles"
) > "%SRC_DIR%\setup.cfg"

python -m pip install "%SRC_DIR%"
