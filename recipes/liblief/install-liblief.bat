pushd build
  cmake --build . -j %CPU_COUNT% --config Release --target install -- -verbosity:normal

:: cmake --build . --target INSTALL --config Release -- -j%CPU_COUNT%
:: Racey:
:: cmake --build . --target INSTALL --config Release -- -j%CPU_COUNT%
  if errorlevel 1 exit /b 1
popd
