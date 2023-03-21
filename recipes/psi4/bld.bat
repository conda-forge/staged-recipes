dir "%LIBRARY_PREFIX%\\lib"

cmake %CMAKE_ARGS% ^
  -G"Ninja" ^
  -S%SRC_DIR% ^
  -Bbuild ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DCMAKE_C_COMPILER=clang-cl ^
  -DCMAKE_CXX_COMPILER=clang-cl ^
  -DCMAKE_INSTALL_LIBDIR="lib" ^
  -DCMAKE_INSTALL_INCLUDEDIR="include" ^
  -DCMAKE_INSTALL_BINDIR="bin" ^
  -DCMAKE_INSTALL_DATADIR="share" ^
  -DPYMOD_INSTALL_LIBDIR="/../../Lib/site-packages" ^
  -DPython_EXECUTABLE="%PYTHON%" ^
  -DLAPACK_LIBRARIES="%PREFIX%\\Library\\lib\\mkl_rt.lib" ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DENABLE_OPENMP=ON ^
  -DCMAKE_INSIST_FIND_PACKAGE_gau2grid=ON ^
  -DMAX_AM_ERI=5 ^
  -DCMAKE_INSIST_FIND_PACKAGE_Libint2=ON ^
  -DCMAKE_INSIST_FIND_PACKAGE_pybind11=ON ^
  -DCMAKE_INSIST_FIND_PACKAGE_Libxc=ON ^
  -DCMAKE_INSIST_FIND_PACKAGE_qcelemental=ON ^
  -DCMAKE_INSIST_FIND_PACKAGE_qcengine=ON ^
  -DENABLE_XHOST=OFF ^
  -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"

if errorlevel 1 exit 1

::                -DCMAKE_VERBOSE_MAKEFILE=OFF
::                -DCMAKE_CXX_FLAGS="/arch:AVX"
::                -DPython_NumPy_INCLUDE_DIR="C:/tools/miniconda3/lib/site-packages/numpy/core/include"
::                -DEigen3_ROOT="C:/tools/miniconda3/Library"
::                -DBOOST_ROOT="C:/tools/miniconda3/Library"
::                -DMultiprecision_ROOT="C:/tools/miniconda3/Library"
::      -DCMAKE_C_FLAGS="/wd4018 /wd4101 /wd4996 /EHsc %CFLAGS%"
::      -DCMAKE_CXX_FLAGS="/wd4018 /wd4101 /wd4996 /EHsc %CXXFLAGS%"

cd build
cmake --build . ^
      --config Release ^
      --target install ^
      -- -j %CPU_COUNT%
if errorlevel 1 exit 1

:: tests outside build phase

::  -DCMAKE_C_FLAGS="${CFLAGS}" \
::  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
::  -DPYMOD_INSTALL_LIBDIR="/python${PY_VER}/site-packages" \
::  -DLAPACK_LIBRARIES="${PREFIX}/lib/libmkl_rt${SHLIB_EXT}" \

::    - md {{ PREFIX }}\Scripts
::    - copy /y {{ INSTALL_DIR }}\bin\psi4 {{ PREFIX }}\Scripts
::    - echo __pycache__ > exclude.txt
::    - xcopy /f /i /s /exclude:exclude.txt {{ INSTALL_DIR }}\lib\psi4 {{ SP_DIR }}\psi4
::    - xcopy /f /i /s {{ INSTALL_DIR }}\share\psi4\basis       {{ PREFIX }}\Lib\share\psi4\basis
::    - xcopy /f /i /s {{ INSTALL_DIR }}\share\psi4\plugin      {{ PREFIX }}\Lib\share\psi4\plugin
::    - xcopy /f /i /s {{ INSTALL_DIR }}\share\psi4\quadratures {{ PREFIX }}\Lib\share\psi4\quadratures
::    - xcopy /f /i /s {{ INSTALL_DIR }}\share\psi4\databases   {{ PREFIX }}\Lib\share\psi4\databases
::    - xcopy /f /i /s {{ INSTALL_DIR }}\share\psi4\fsapt       {{ PREFIX }}\Lib\share\psi4\fsapt
::    - xcopy /f /i /s {{ INSTALL_DIR }}\share\psi4\grids       {{ PREFIX }}\Lib\share\psi4\grids

