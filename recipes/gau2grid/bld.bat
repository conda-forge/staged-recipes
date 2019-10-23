::%BUILD_PREFIX%/bin/cmake ^
::    -G "%CMAKE_GENERATOR%" ^

mkdir build
cd build

cmake -G "%CMAKE_GENERATOR%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_LIBDIR="%LIBRARY_LIB%" ^
    -DCMAKE_INSTALL_INCLUDEDIR="%LIBRARY_INC%" ^
    -DCMAKE_INSTALL_BINDIR="%LIBRARY_BIN%" ^
    -DCMAKE_INSTALL_DATADIR="%LIBRARY_PREFIX%" ^
    -DPYMOD_INSTALL_LIBDIR="/python%PY_VER%/site-packages" ^
    -DINSTALL_PYMOD=ON ^
    -DBUILD_SHARED_LIBS=ON ^
    -DENABLE_GENERIC=ON ^
    -DPYTHON_EXECUTABLE=%PYTHON% ^
    -DMAX_AM=8 ^
    %SRC_DIR%

:: set "INCLUDE=%PREFIX%\Library\include;%PREFIX%\Library\include;"  
:: set "LIB=%PREFIX%\Library\lib;%PREFIX%\Library\lib;"  
:: set "CMAKE_PREFIX_PATH=%PREFIX%\Library;" 

::cd build
cmake --build . ^
      --config Release ^
      --target install
::      ::-- -j %CPU_COUNT%
::if errorlevel 1 exit 1

::mkdir build
::cd build
::
::cmake   -G "%CMAKE_GENERATOR%" ^
::        -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
::        -DCMAKE_INSTALL_LIBDIR="%LIBRARY_LIB%" ^
::        -DCMAKE_INSTALL_INCLUDEDIR="%LIBRARY_INC%" ^
::        -DCMAKE_INSTALL_BINDIR="%LIBRARY_BIN%" ^
::        -DCMAKE_INSTALL_DATADIR="%LIBRARY_PREFIX%" ^
::        -DPYMOD_INSTALL_LIBDIR="/python%PY_VER%/site-packages" ^
::        -DINSTALL_PYMOD=ON ^
::        -DBUILD_SHARED_LIBS=ON ^
::        -DENABLE_GENERIC=ON ^
::        -DPYTHON_EXECUTABLE=%PYTHON% ^
::        -DMAX_AM=8 ^
::        ..
::
::cmake --build . --target INSTALL --config Release

:::: %BUILD_PREFIX%/bin/cmake ^
::cmake -G Ninja ^
::        -H%SRC_DIR% ^
::        -Bbuild ^
::        -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    ::        -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
::        -DCMAKE_BUILD_TYPE=Release ^
::        -DCMAKE_INSTALL_LIBDIR=lib ^
::        -DPYMOD_INSTALL_LIBDIR="/python%PY_VER%/site-packages" ^
::        -DINSTALL_PYMOD=ON ^
::        -DBUILD_SHARED_LIBS=ON ^
::        -DENABLE_GENERIC=ON ^
::        -DPYTHON_EXECUTABLE=%PYTHON% ^
::        -DMAX_AM=8
::if errorlevel 1 exit 1
::        ::-DCMAKE_C_FLAGS="%CFLAGS%" ^
::        ::-DCMAKE_C_COMPILER=clang-cl ^
::        ::-DCARTESIAN_ORDER=row ^
::        ::-DSPHERICAL_ORDER=gaussian ^
::
::cd build
::cmake --build . ^
::      --config Release
::      ::--config Release ^
::      ::-- -j %CPU_COUNT%
::if errorlevel 1 exit 1
::
::cmake --build . ^
::      --config Release ^
::      --target install
::      ::--target install ^
::      ::-- -j %CPU_COUNT%
::if errorlevel 1 exit 1
::
:::: tests outside build phase
