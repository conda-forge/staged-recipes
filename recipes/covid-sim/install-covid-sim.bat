set CFG=Release
pushd src
  mkdir %PREFIX%\Library\bin || true
  copy %CFG%\CovidSim.exe %PREFIX%\Library\bin\
  if not ErrorLevel 0 exit /b 1
popd
