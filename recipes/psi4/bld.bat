
cmake %CMAKE_ARGS% ^
  -G "Ninja" ^
  -S %SRC_DIR% ^
  -B build ^
  -D CMAKE_BUILD_TYPE=Release ^
  -D CMAKE_INSTALL_PREFIX="%PREFIX%" ^
  -D CMAKE_C_COMPILER=clang-cl ^
  -D CMAKE_C_FLAGS="%CFLAGS%" ^
  -D CMAKE_CXX_COMPILER=clang-cl ^
  -D CMAKE_CXX_FLAGS="%CXXFLAGS%" ^
  -D CMAKE_INSTALL_LIBDIR="Library\lib" ^
  -D CMAKE_INSTALL_INCLUDEDIR="Library\include" ^
  -D CMAKE_INSTALL_BINDIR="Scripts" ^
  -D CMAKE_INSTALL_DATADIR="Library\share" ^
  -D PYMOD_INSTALL_LIBDIR="/../../Lib/site-packages" ^
  -D psi4_INSTALL_CMAKEDIR="Library\share\cmake\psi4" ^
  -D TargetLAPACK_INSTALL_CMAKEDIR="Library\share\cmake\TargetLAPACK" ^
  -D TargetHDF5_INSTALL_CMAKEDIR="Library\share\cmake\TargetHDF5" ^
  -D Python_EXECUTABLE="%PYTHON%" ^
  -D LAPACK_LIBRARIES="%PREFIX%\\Library\\lib\\mkl_rt.lib" ^
  -D OpenMP_LIBRARY_DIRS="%SRC_DIR%\\external_src\\conda\\win\\2019.1" ^
  -D BUILD_SHARED_LIBS=OFF ^
  -D ENABLE_OPENMP=ON ^
  -D CMAKE_INSIST_FIND_PACKAGE_gau2grid=ON ^
  -D MAX_AM_ERI=5 ^
  -D CMAKE_INSIST_FIND_PACKAGE_Libint2=ON ^
  -D CMAKE_INSIST_FIND_PACKAGE_pybind11=ON ^
  -D CMAKE_INSIST_FIND_PACKAGE_Libxc=ON ^
  -D CMAKE_INSIST_FIND_PACKAGE_qcelemental=ON ^
  -D CMAKE_INSIST_FIND_PACKAGE_qcengine=ON ^
  -D psi4_SKIP_ENABLE_Fortran=ON ^
  -D ENABLE_dkh=ON ^
  -D CMAKE_INSIST_FIND_PACKAGE_dkh=ON ^
  -D ENABLE_XHOST=OFF ^
  -D CMAKE_VERBOSE_MAKEFILE=OFF ^
  -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"

if errorlevel 1 exit 1

cmake --build build ^
      --config Release ^
      --target install ^
      -- -j %CPU_COUNT%
if errorlevel 1 exit 1

:: Relocate python module to expected location (if positioning through PYMOD_INSTALL_LIBDIR="/" and CMAKE_INSTALL_BINDIR="Library\bin")
::copy /y "%PREFIX%\Library\bin\psi4" "%PREFIX%\Scripts"
::if errorlevel 1 exit 1
:: xcopy /f /i /s /y "%PREFIX%\Library\lib\psi4" "%SP_DIR%\psi4"
:: if errorlevel 1 exit 1
:: del /S /Q "%PREFIX%\Library\lib\psi4"
:: if errorlevel 1 exit 1

:: only available with m2w64-binutils package - add dep in meta.yaml or defer to test stage
objdump.exe -p %PREFIX%\Lib\site-packages\psi4\core.*.pyd | findstr /i "dll"
objdump.exe -p %PREFIX%\Library\bin\mkl_rt.*.dll | findstr /i "dll"

:: tests outside build phase


::md {{ PREFIX }}\Scripts
::copy /y {{ INSTALL_DIR }}\bin\psi4 {{ PREFIX }}\Scripts
::echo __pycache__ > exclude.txt
::xcopy /f /i /s /exclude:exclude.txt {{ INSTALL_DIR }}\lib\psi4 {{ SP_DIR }}\psi4
::xcopy /f /i /s {{ INSTALL_DIR }}\share\psi4\basis       {{ PREFIX }}\Lib\share\psi4\basis
::xcopy /f /i /s {{ INSTALL_DIR }}\share\psi4\plugin      {{ PREFIX }}\Lib\share\psi4\plugin
::xcopy /f /i /s {{ INSTALL_DIR }}\share\psi4\quadratures {{ PREFIX }}\Lib\share\psi4\quadratures
::xcopy /f /i /s {{ INSTALL_DIR }}\share\psi4\databases   {{ PREFIX }}\Lib\share\psi4\databases
::xcopy /f /i /s {{ INSTALL_DIR }}\share\psi4\fsapt       {{ PREFIX }}\Lib\share\psi4\fsapt
::xcopy /f /i /s {{ INSTALL_DIR }}\share\psi4\grids       {{ PREFIX }}\Lib\share\psi4\grids
::if errorlevel 1 exit 1

::                -DCMAKE_CXX_FLAGS="/arch:AVX"
::                -DPython_NumPy_INCLUDE_DIR="C:/tools/miniconda3/lib/site-packages/numpy/core/include"
::                -DEigen3_ROOT="C:/tools/miniconda3/Library"
::                -DBOOST_ROOT="C:/tools/miniconda3/Library"
::                -DMultiprecision_ROOT="C:/tools/miniconda3/Library"
::      -DCMAKE_C_FLAGS="/wd4018 /wd4101 /wd4996 /EHsc %CFLAGS%"
::      -DCMAKE_CXX_FLAGS="/wd4018 /wd4101 /wd4996 /EHsc %CXXFLAGS%"

