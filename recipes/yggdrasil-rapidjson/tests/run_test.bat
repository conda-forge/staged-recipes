setlocal EnableDelayedExpansion

for %%x in (serialize yggdrasil units) do (
  echo Building %%x
  dir
  set "builddir=example\\%%x\\build"
  echo !builddir!
  if not exist "!builddir!" mkdir "!builddir!"
  if !errorlevel! neq 0 exit /b !errorlevel!
  cd "!builddir!"
  cmake -G "Ninja" ^
        -D CMAKE_VERBOSE_MAKEFILE:BOOL=ON ^
        ..
  if !errorlevel! neq 0 exit /b !errorlevel!
  cmake --build . --config Debug
  if !errorlevel! neq 0 exit /b !errorlevel!

  echo Running %%x
  %%x.exe
  if !errorlevel! neq 0 exit /b !errorlevel!

  cd ..\\..\\..
)
