
cmake %CMAKE_ARGS% ^
  -G"Ninja" ^
  -S%SRC_DIR% ^
  -Bbuild ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
  -DCMAKE_C_COMPILER=clang-cl ^
  -DCMAKE_CXX_COMPILER=clang-cl ^
  -DCMAKE_INSTALL_LIBDIR="Library\lib" ^
  -DCMAKE_INSTALL_INCLUDEDIR="Library\include" ^
  -DCMAKE_INSTALL_BINDIR="Library\bin" ^
  -DCMAKE_INSTALL_DATADIR="Library\share" ^
  -DPython_EXECUTABLE="%PYTHON%" ^
  -DLAPACK_LIBRARIES="%PREFIX%\\Library\\lib\\mkl_rt.lib" ^
  -DOpenMP_LIBRARY_DIRS="%SRC_DIR%\\external_src\\conda\\win\\2019.1" ^
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
  -DCMAKE_VERBOSE_MAKEFILE=OFF ^
  -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"

if errorlevel 1 exit 1


::  -DPYMOD_INSTALL_LIBDIR="/../../Lib/site-packages"
::  -DOpenMP_LIBRARY_DIRS="D:\a\psi4\psi4\iomp5md\conda\win\2019.1"

::2023-03-21T18:48:00.7500384Z -- Installing: C:/bld/psi4_1679421472503/_h_env/Lib/site-packages/psi4/core.cp39-win_amd64.pyd

:: -- Detecting MathOpenMP -- ?OpenMP=ON, ?MKL= MKL, LANG=CXX, C/CXX/Fortran=Clang/Clang/
:: -- Could NOT find OpenMP_CXX (missing: OpenMP_CXX_FLAGS OpenMP_CXX_LIB_NAMES)
:: -- Could NOT find OpenMP (missing: OpenMP_CXX_FOUND CXX)
:: -- CMake FindOpenMP failed! Trying a custom OpenMP configuration...
:: -- Performing Test USE_CLANG_CL_CXX
:: -- Performing Test USE_CLANG_CL_CXX - Success
:: -- OpenMP::OpenMP_CXX target constructed (D:/a/psi4/psi4/iomp5md/conda/win/2019.1/libiomp5md.lib)
:: -- Found TargetOpenMP: 1  found components: CXX
:: -- Found MathOpenMP: 1
:: -- Using LAPACK MKL: C:/Miniconda/envs/baseenv/Library/lib/mkl_rt.lib;...
:: -- Disabled HDF5

:: 2023-03-21T16:10:31.3191616Z -- Detecting MathOpenMP -- ?OpenMP=ON, ?MKL= MKL, LANG=CXX, C/CXX/Fortran=Clang/Clang/
:: 2023-03-21T16:10:31.3192661Z -- Could NOT find OpenMP_CXX (missing: OpenMP_CXX_FLAGS OpenMP_CXX_LIB_NAMES)
:: 2023-03-21T16:10:31.3194029Z -- Could NOT find OpenMP (missing: OpenMP_CXX_FOUND CXX)
:: 2023-03-21T16:10:31.3195044Z -- CMake FindOpenMP failed! Trying a custom OpenMP configuration...
:: 2023-03-21T16:10:31.3195878Z -- Performing Test USE_CLANG_CL_CXX
:: 2023-03-21T16:10:31.3196756Z -- Performing Test USE_CLANG_CL_CXX - Success
:: 2023-03-21T16:10:31.3198368Z -- OpenMP::OpenMP_CXX target constructed (C:/Program Files (x86)/Microsoft Visual Studio/2019/Enterprise/VC/Tools/Llvm/x64/lib/libiomp5md.lib)
:: 2023-03-21T16:10:31.3199396Z -- Found TargetOpenMP: 1  found components: CXX
:: 2023-03-21T16:10:31.3200125Z -- Found MathOpenMP: 1
:: 2023-03-21T16:10:31.3200634Z -- Using LAPACK MKL: %PREFIX%\\Library\\lib\\mkl_rt.lib;...
:: 2023-03-21T16:10:31.3201065Z -- Disabled HDF5

::2023-03-21T06:48:10.6659195Z ninja: error: 'C:/bld/psi4_1679380787794/_h_env/Library/lib/mkl_rt.lib', needed by 'src/core.cp39-win_amd64.pyd', missing and no known rule to make it

::                -DCMAKE_CXX_FLAGS="/arch:AVX"
::                -DPython_NumPy_INCLUDE_DIR="C:/tools/miniconda3/lib/site-packages/numpy/core/include"
::                -DEigen3_ROOT="C:/tools/miniconda3/Library"
::                -DBOOST_ROOT="C:/tools/miniconda3/Library"
::                -DMultiprecision_ROOT="C:/tools/miniconda3/Library"
::      -DCMAKE_C_FLAGS="/wd4018 /wd4101 /wd4996 /EHsc %CFLAGS%"
::      -DCMAKE_CXX_FLAGS="/wd4018 /wd4101 /wd4996 /EHsc %CXXFLAGS%"

cmake --build build ^
      --config Release ^
      --target install ^
      -- -j %CPU_COUNT%
if errorlevel 1 exit 1

:: Relocate python module to expected location (if positioning through PYMOD_INSTALL_LIBDIR="/")
copy /y "%PREFIX%\Library\bin\psi4" "%PREFIX%\Scripts"
if errorlevel 1 exit 1
xcopy /f /i /s /y "%PREFIX%\Library\lib\psi4" "%SP_DIR%\psi4"
if errorlevel 1 exit 1
del /S /Q "%PREFIX%\Library\lib\psi4"
if errorlevel 1 exit 1

:: only available with m2w64-binutils package - add dep in meta.yaml or defer to test stage
objdump.exe -p %PREFIX%\Lib\site-packages\psi4\core.*.pyd | findstr /i "dll"
objdump.exe -p %PREFIX%\Library\bin\mkl_rt.*.dll | findstr /i "dll"

:: tests outside build phase

:: #2023-03-22T19:13:22.2662192Z -- Installing: C:/bld/psi4_1679509717843/_h_env/Library/bin/psi4
:: #2023-03-22T19:13:22.2689516Z -- Installing: C:/bld/psi4_1679509717843/_h_env/Library/bin/psi4.bat

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


::  -DCMAKE_C_FLAGS="${CFLAGS}" \
::  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
::  -DPYMOD_INSTALL_LIBDIR="/python${PY_VER}/site-packages" \
::  -DLAPACK_LIBRARIES="${PREFIX}/lib/libmkl_rt${SHLIB_EXT}" \


::  -G"Ninja" 
::  -S%SRC_DIR% 
::  -Bbuild 
::  -DCMAKE_BUILD_TYPE=Release 
::  -DCMAKE_INSTALL_PREFIX="%PREFIX%" 
::  -DCMAKE_C_COMPILER=clang-cl 
::  -DCMAKE_CXX_COMPILER=clang-cl 
::  -DCMAKE_INSTALL_LIBDIR="Library\lib" 
::  -DCMAKE_INSTALL_INCLUDEDIR="Library\include" 
::  -DCMAKE_INSTALL_BINDIR="Library\bin" 
::  -DCMAKE_INSTALL_DATADIR="Library\share" 
::  -DPYMOD_INSTALL_LIBDIR="\..\..\Lib\site-packages" 

