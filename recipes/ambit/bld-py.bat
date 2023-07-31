
cmake %CMAKE_ARGS% ^
  -G "Ninja" ^
  -S "%SRC_DIR%\\pyambit" ^
  -B "build_py%PY_VER%" ^
  -D CMAKE_BUILD_TYPE=Release ^
  -D CMAKE_INSTALL_PREFIX="%PREFIX%" ^
  -D CMAKE_C_COMPILER=clang-cl ^
  -D CMAKE_C_FLAGS="/EHsc %CFLAGS%" ^
  -D CMAKE_CXX_COMPILER=clang-cl ^
  -D CMAKE_CXX_FLAGS="/EHsc -Xclang -fopenmp %CXXFLAGS%" ^
  -D CMAKE_INSTALL_LIBDIR="Library\lib" ^
  -D CMAKE_INSTALL_INCLUDEDIR="Library\include" ^
  -D CMAKE_INSTALL_BINDIR="Library\bin" ^
  -D CMAKE_INSTALL_DATADIR="Library\share" ^
  -D PYMOD_INSTALL_LIBDIR="/../../Lib/site-packages" ^
  -D ambit_INSTALL_CMAKEDIR="Library\share\cmake\ambit" ^
  -D Python_EXECUTABLE="%PYTHON%" ^
  -D LAPACK_LIBRARIES="%PREFIX%\\Library\\lib\\lapack.lib;%PREFIX%\\Library\\lib\\blas.lib;%SRC_DIR%\\external_src\\conda\\win\\2019.1\\libiomp5md.lib" ^
  -D ENABLE_OPENMP=ON ^
  -D CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
  -D CMAKE_VERBOSE_MAKEFILE=OFF ^
  -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"
if errorlevel 1 exit 1

cmake --build build_py%PY_VER% ^
      --config Release ^
      --target install ^
      -- -j %CPU_COUNT%
if errorlevel 1 exit 1

REM pytest in conda testing stage


REM pyambit builds and imports and starts just fine, but it fails at anything complicated, hence the build/skip. output from test_ambit.py below

REM before
REM initialized
REM fill dims=[9, 7]
REM <ambit.pyambit.Tensor object at 0x0000016EA1F1AEB0>
REM [[0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0]]

