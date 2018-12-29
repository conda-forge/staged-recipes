set YEAR=2017
set VER=15

mkdir "%PREFIX%\etc\conda\activate.d"
COPY "%RECIPE_DIR%\activate.bat" "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"

IF "%cross_compiler_target_platform%" == "win-64" (
  set "target_platform=amd64"
  echo SET "CMAKE_GENERATOR=Visual Studio %VER% %YEAR% Win64" >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
  echo pushd "%%VSINSTALLDIR%%" >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
  echo CALL "VC\Auxiliary\Build\vcvars64.bat" >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
  echo popd >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
  ) else (
  set "target_platform=x86"
  echo SET "CMAKE_GENERATOR=Visual Studio %VER% %YEAR%" >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
  echo pushd "%%VSINSTALLDIR%%" >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
  echo CALL "VC\Auxiliary\Build\vcvars32.bat" >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
  echo popd >> "%PREFIX%\etc\conda\activate.d\vs%YEAR%_compiler_vars.bat"
  )


