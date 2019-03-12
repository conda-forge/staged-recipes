pushd build
  cmake --build . --target INSTALL --config Release -- -j%CPU_COUNT%
  if errorlevel 1 exit /b 1
popd
