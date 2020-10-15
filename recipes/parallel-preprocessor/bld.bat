git submodule update --init --recursive

mkdir build-conda
cd build-conda

cmake ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DPPP_USE_TEST=OFF ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_LIBDIR=%LIBRARY_LIB% ^
    -G "NMake Makefiles" ..
if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1

REM python package built and installed to site-package by cmake, no need to run setup.py

