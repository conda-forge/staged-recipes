  mkdir build
  cd build
  cmake ^
    -DCMAKE_INSTALL_PREFIX=%CONDA_PREFIX% ^
    ..
  cmake --build . --config Release --parallel %NUMBER_OF_PROCESSORS%
  cmake --build . --config Release --target install