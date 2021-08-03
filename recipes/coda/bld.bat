cmake ^
  -G"Visual Studio 14 2015 Win64" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCODA_ENABLE_CONDA_INSTALL=True ^
  -DCODA_BUILD_PYTHON=True ^
  -DCODA_WITH_HDF4=True ^
  -DCODA_WITH_HDF5=True ^
  -DZLIB_INCLUDE_DIR=%LIBRARY_INC% ^
  -DJPEG_INCLUDE_DIR=%LIBRARY_INC% ^
  -DHDF4_INCLUDE_DIR=%LIBRARY_INC% ^
  -DHDF5_INCLUDE_DIR=%LIBRARY_INC% ^
  -DNUMPY_INCLUDE_DIR:PATH="%SP_DIR%/numpy/core/include" ^
  -DCMAKE_INSTALL_PREFIX:PATH=%PREFIX%
if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1
