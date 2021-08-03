cmake ^
  -G"Visual Studio 14 2015 Win64" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DHARP_ENABLE_CONDA_INSTALL=True ^
  -DHARP_BUILD_PYTHON=True ^
  -DHARP_BUILD_R=True ^
  -DCODA_INCLUDE_DIR="%LIBRARY_INC%" ^
  -DJPEG_INCLUDE_DIR="%LIBRARY_INC%" ^
  -DHDF4_INCLUDE_DIR="%LIBRARY_INC%" ^
  -DHDF5_INCLUDE_DIR="%LIBRARY_INC%" ^
  -DCMAKE_INSTALL_PREFIX:PATH=%PREFIX%
if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1
