
cmake -G"Ninja" ^
      -S%SRC_DIR% ^
      -Bbuild ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
      -DCMAKE_INSTALL_LIBDIR="Library\lib" ^
      -DCMAKE_INSTALL_INCLUDEDIR="Library\include" ^
      -DCMAKE_INSTALL_BINDIR="Library\bin" ^
      -DCMAKE_INSTALL_DATADIR="Library\share" ^
      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -DPYLIBEFP_CMAKECONFIG_INSTALL_DIR="Library\share\cmake\pylibefp" ^
      -DLIBEFP_CMAKECONFIG_INSTALL_DIR="Library\share\cmake\libefp" ^
      -DCMAKE_C_FLAGS="/wd4018 /wd4101 /wd4996 /EHsc %CFLAGS%" ^
      -DCMAKE_CXX_FLAGS="/wd4018 /wd4101 /wd4996 /EHsc %CXXFLAGS%" ^
      -DPYMOD_INSTALL_LIBDIR="\..\..\Lib\site-packages" ^
      -DPYTHON_EXECUTABLE="%PYTHON%" ^
      -DPython_EXECUTABLE="%PYTHON%" ^
      -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
      -DBUILD_SHARED_LIBS=ON ^
      -DENABLE_OPENMP=OFF ^
      -DCMAKE_INSIST_FIND_PACKAGE_pybind11=ON ^
      -DCMAKE_INSIST_FIND_PACKAGE_qcelemental=ON ^
      -DCMAKE_DISABLE_FIND_PACKAGE_libefp=ON ^
      -DENABLE_XHOST=OFF ^
      -DBUILD_TESTING=OFF ^
      -DFRAGLIB_UNDERSCORE_L=OFF ^
      -DFRAGLIB_DEEP=OFF ^
      -DINSTALL_DEVEL_HEADERS=ON

      ::-DLAPACK_LIBRARIES="%PREFIX%/Library/lib/mkl_rt.lib"
if errorlevel 1 exit 1

cd build
cmake --build . ^
      --config Release ^
      --target install ^
      -- -j %CPU_COUNT%
if errorlevel 1 exit 1

:: tests outside build phase

:: Relocate python scripts to expected location (if positioning through PYMOD_INSTALL_LIBDIR="/")
::xcopy /f /i /s /y "%PREFIX%\Library\lib\pylibefp" "%SP_DIR%\pylibefp"
::if errorlevel 1 exit 1
