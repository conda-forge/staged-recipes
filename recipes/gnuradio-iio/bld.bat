setlocal EnableDelayedExpansion
@echo on

:: define NOMINMAX since gnuradio headers expect min/max to be functions not macros
set "CFLAGS=%CFLAGS% -DNOMINMAX"
set "CXXFLAGS=%CXXFLAGS% -DNOMINMAX"

:: so win_bison can locate it's data in the conda environment
set "BISON_PKGDATADIR=%LIBRARY_PREFIX%\\share\\winflexbison\\data"

:: Make a build folder and change to it
mkdir build
cd build

:: configure
:: enable components explicitly so we get build error when unsatisfied
cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DPYTHON_EXECUTABLE:PATH="%PYTHON%" ^
    -DBoost_NO_BOOST_CMAKE=ON ^
    -DAD9361_LIBRARIES:FILEPATH="%LIBRARY_PREFIX%\\lib\\libad9361.lib" ^
    -DGR_PYTHON_DIR:PATH="%SP_DIR%" ^
    -DIIO_LIBRARIES:FILEPATH="%LIBRARY_PREFIX%\\lib\\libiio.lib" ^
    -DMPIR_LIBRARY="%LIBRARY_LIB%\mpir.lib" ^
    -DMPIRXX_LIBRARY="%LIBRARY_LIB%\mpir.lib" ^
    -DENABLE_DOXYGEN=OFF ^
    ..
if errorlevel 1 exit 1

:: build
cmake --build . --config Release -- -j%CPU_COUNT%
if errorlevel 1 exit 1

:: install
cmake --build . --config Release --target install
if errorlevel 1 exit 1
