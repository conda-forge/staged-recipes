@echo on
setlocal EnableExtensions

cmake -S nceplibs-g2c -B build-g2c -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_C_COMPILER=x86_64-w64-mingw32-gcc ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DBUILD_STATIC_LIBS=ON ^
  -DBUILD_TESTING=OFF ^
  -DUTILS=OFF
if errorlevel 1 exit /b 1
cmake --build build-g2c --parallel %CPU_COUNT%
if errorlevel 1 exit /b 1

cmake -S . -B build -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_C_COMPILER=x86_64-w64-mingw32-gcc ^
  -DGRADS_G2C_LIBRARY=%SRC_DIR%\build-g2c\src\libg2c.a ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%
if errorlevel 1 exit /b 1

cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit /b 1
cmake --install build
if errorlevel 1 exit /b 1

if not exist "%LIBRARY_PREFIX%\share\grads" mkdir "%LIBRARY_PREFIX%\share\grads"
xcopy /E /I /Y data "%LIBRARY_PREFIX%\share\grads"
if errorlevel 1 exit /b 1

(
  echo # Type     Name     Full path to shared object file
  echo gxdisplay  Cairo    %LIBRARY_BIN%\libgxdCairo.dll
  echo gxdisplay  X11      %LIBRARY_BIN%\libgxdX11.dll
  echo gxdisplay  gxdummy  %LIBRARY_BIN%\libgxdummy.dll
  echo *
  echo gxprint    Cairo    %LIBRARY_BIN%\libgxpCairo.dll
  echo gxprint    GD       %LIBRARY_BIN%\libgxpGD.dll
  echo gxprint    gxdummy  %LIBRARY_BIN%\libgxdummy.dll
) > "%LIBRARY_PREFIX%\share\grads\udpt"

if not exist "%PREFIX%\etc\conda\activate.d" mkdir "%PREFIX%\etc\conda\activate.d"
if not exist "%PREFIX%\etc\conda\deactivate.d" mkdir "%PREFIX%\etc\conda\deactivate.d"

(
  echo @set "GADDIR_BACKUP=%%GADDIR%%"
  echo @set "GAUDPT_BACKUP=%%GAUDPT%%"
  echo @set "GAGPY_BACKUP=%%GAGPY%%"
  echo @set "GADDIR=%LIBRARY_PREFIX%\share\grads"
  echo @set "GAUDPT=%LIBRARY_PREFIX%\share\grads\udpt"
  echo @set "GAGPY=%LIBRARY_BIN%\gradspy.dll"
) > "%PREFIX%\etc\conda\activate.d\grads-env.bat"

(
  echo @set "GADDIR=%%GADDIR_BACKUP%%"
  echo @set "GAUDPT=%%GAUDPT_BACKUP%%"
  echo @set "GAGPY=%%GAGPY_BACKUP%%"
  echo @set GADDIR_BACKUP=
  echo @set GAUDPT_BACKUP=
  echo @set GAGPY_BACKUP=
) > "%PREFIX%\etc\conda\deactivate.d\grads-env.bat"

endlocal
