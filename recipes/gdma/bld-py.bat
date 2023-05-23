set "CXX=g++.exe"

cmake %CMAKE_ARGS% ^
  -G "Ninja" ^
  -S "%SRC_DIR%\\pygdma" ^
  -B "build_py%PY_VER%" ^
  -D CMAKE_BUILD_TYPE=Release ^
  -D CMAKE_INSTALL_PREFIX="%PREFIX%" ^
  -D CMAKE_CXX_FLAGS="/EHsc %CXXFLAGS%" ^
  -D CMAKE_INSTALL_LIBDIR="Library\lib" ^
  -D CMAKE_INSTALL_INCLUDEDIR="Library\include" ^
  -D CMAKE_INSTALL_BINDIR="Library\bin" ^
  -D CMAKE_INSTALL_DATADIR="Library\share" ^
  -D PYMOD_INSTALL_LIBDIR="/../../Lib/site-packages" ^
  -D gdma_INSTALL_CMAKEDIR="Library\share\cmake\gdma" ^
  -D Python_EXECUTABLE="%PYTHON%" ^
  -D CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
  -D CMAKE_VERBOSE_MAKEFILE=OFF ^
  -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"
if errorlevel 1 exit 1

cmake --build build_py%PY_VER% ^
      --config Release ^
      --target install ^
      -- -j %CPU_COUNT%
if errorlevel 1 exit 1

::REM pytest in conda testing stage
::
::
::REM pyambit builds and imports and starts just fine, but it fails at anything complicated, hence the build/skip. output from test_ambit.py below
::
::REM before
::REM initialized
::REM fill dims=[9, 7]
::REM <ambit.pyambit.Tensor object at 0x0000016EA1F1AEB0>
::REM [[0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0]]

