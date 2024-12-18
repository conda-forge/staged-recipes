@echo off
setlocal enabledelayedexpansion
set SRC_DIR=%SRC_DIR%
set PKG_NAME=%PKG_NAME%
set PREFIX=%PREFIX%

pushd !SRC_DIR! || exit /b 1
  :: Get current and age from meson
  for /f "tokens=2 delims=: " %%i in ('meson introspect build-!PKG_NAME! --projectinfo ^| findstr "current"') do set CURRENT=%%i
  set CURRENT=%CURRENT:,=%
  for /f "tokens=2 delims=: " %%i in ('meson introspect build-!PKG_NAME! --projectinfo ^| findstr "age"') do set AGE=%%i
  set AGE=%AGE:,=%
  set /a VERSION=CURRENT-AGE

  meson setup build-!PKG_NAME! ^
    --prefix=!PREFIX!\Library ^
    --buildtype=release ^
    --strip ^
    --backend=ninja ^
    --default-library=shared ^
    -Dc_args="-D_CRT_SECURE_NO_WARNINGS -D_WINSOCK_DEPRECATED_NO_WARNINGS"
   if errorlevel 1 exit 1

  meson compile -C build-!PKG_NAME!
  if errorlevel 1 exit 1

  meson install -C build-!PKG_NAME!
  if errorlevel 1 exit 1

  :: Create non-versioned .dll
  copy /Y !PREFIX!\Library\bin\libjaylink-%VERSION%.dll !PREFIX!\Library\bin\libjaylink.dll
  if errorlevel 1 exit 1

  copy /Y !PREFIX!\Library\bin\jaylink-%VERSION%.dll !PREFIX!\Library\bin\jaylink.dll
  if errorlevel 1 exit 1

  :: Create .dll.a file
  dlltool -d libjaylink\jaylink.def --dllname libjaylink-%VERSION%.dll --output-lib !PREFIX!\Library\lib\libjaylink-%VERSION%.dll.a
  if errorlevel 1 exit 1

  dlltool -d libjaylink\jaylink.def --dllname libjaylink.dll --output-lib !PREFIX!\Library\lib\libjaylink.dll.a
  if errorlevel 1 exit 1

  dumpbin /symbols !PREFIX!\Library\lib\libjaylink.lib | findstr "jaylink_"

  echo "Checking symbols in .dll and .dll.a files"
  nm -g !PREFIX!\Library\lib\libjaylink.dll.a | findstr "jaylink"
  objdump -x !PREFIX!\Library\lib\libjaylink.dll.a | findstr "jaylink"
  echo "Checking symbols in .dll files"

  objdump -p !PREFIX!\Library\bin\libjaylink-%VERSION%.dll | findstr "jaylink_"
  objdump -p !PREFIX!\Library\bin\libjaylink.dll | findstr "jaylink_"

popd || exit /b 1
