cmake -G "%CMAKE_GENERATOR%" ^
      -H%SRC_DIR% ^
      -Bbuild ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_LIBDIR="%LIBRARY_LIB%" ^
    -DCMAKE_INSTALL_INCLUDEDIR="%LIBRARY_INC%" ^
    -DCMAKE_INSTALL_BINDIR="%LIBRARY_BIN%" ^
    -DCMAKE_INSTALL_DATADIR="%LIBRARY_PREFIX%" ^
    -DPYMOD_INSTALL_LIBDIR="/../../Lib/site-packages" ^
    -DINSTALL_PYMOD=ON ^
    -DCMAKE_C_FLAGS="/wd4018 /wd4101 /wd4996" ^
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=true ^
    -DBUILD_SHARED_LIBS=ON ^
    -DENABLE_GENERIC=ON ^
    -DPYTHON_EXECUTABLE=%PYTHON% ^
    -DMAX_AM=8
if errorlevel 1 exit 1

::file(TO_NATIVE_PATH "${STAGED_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}${PYMOD_INSTALL_LIBDIR}" _install_lib)

::     Installing: C:/bld/gau2grid_1571869850629/_h_env/Library/include/gau2grid/gau2grid.h
::  -- Installing: C:/bld/gau2grid_1571869850629/_h_env/Library/include/gau2grid/gau2grid_pragma.h
::  -- Installing: C:/bld/gau2grid_1571869850629/_h_env/Library/lib/gg.lib
::  -- Installing: C:/bld/gau2grid_1571869850629/_h_env/Library/share/cmake/gau2grid/gau2gridConfig.cmake
::  -- Installing: C:/bld/gau2grid_1571869850629/_h_env/Library/share/cmake/gau2grid/gau2gridConfigVersion.cmake
::  -- Installing: C:/bld/gau2grid_1571869850629/_h_env/Library/share/cmake/gau2grid/gau2gridTargets.cmake
::  -- Installing: C:/bld/gau2grid_1571869850629/_h_env/Library/share/cmake/gau2grid/gau2gridTargets-release.cmake
::  -- Installing: C:/bld/gau2grid_1571869850629/_h_env/Library/lib/python3.6/site-packages/gau2grid
::  -- Installing: C:/bld/gau2grid_1571869850629/_h_env/Library/lib/python3.6/site-packages/gau2grid/codegen.py
::  -- Installing: C:/bld/gau2grid_1571869850629/_h_env/Library/lib/python3.6/site-packages/gau2grid/c_generator.py
::                                                          Lib/site-packages/numpy/__config__.py
::                                                          Lib/site-packages/numpy/__init__.py
::                                                          Lib/site-packages/numpy/__pycache__/__config__.cpython-36.pyc
::                                                          Lib/site-packages/numpy/__pycache__/__init__.cpython-36.pyc
::

cd build
cmake --build . ^
      --config Release ^
      --target install
::      ::-- -j %CPU_COUNT%
if errorlevel 1 exit 1

:: tests outside build phase




::        ::-DCMAKE_C_FLAGS="%CFLAGS%" ^
::        ::-DCMAKE_C_COMPILER=clang-cl ^

::%BUILD_PREFIX%/bin/cmake ^
