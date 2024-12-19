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
    -Dc_args="-D_CRT_SECURE_NO_WARNINGS -D_WINSOCK_DEPRECATED_NO_WARNINGS -DBUILDING_DLL"
   if errorlevel 1 exit 1

  meson compile -C build-!PKG_NAME!
  if errorlevel 1 exit 1

  meson install -C build-!PKG_NAME!
  if errorlevel 1 exit 1

  :: Create non-versioned .dll
  copy /Y !PREFIX!\Library\bin\libjaylink-%VERSION%.dll !PREFIX!\Library\bin\libjaylink.dll > nul
  if errorlevel 1 exit 1

  copy /Y !PREFIX!\Library\bin\jaylink-%VERSION%.dll !PREFIX!\Library\bin\jaylink.dll > nul
  if errorlevel 1 exit 1

  :: Create .dll.a file

  dumpbin /EXPORTS build-libjaylink\libjaylink\libjaylink.exp > exports.txt
  dumpbin /SYMBOLS build-libjaylink\libjaylink\libjaylink.exp > symbols.txt
  type exports.txt
  type symbols.txt

  dlltool -d libjaylink\jaylink.def ^
          --dllname libjaylink-%VERSION%.dll ^
          --output-lib libjaylink-%VERSION%.dll.a
  if errorlevel 1 exit 1

  copy /Y libjaylink-%VERSION%.dll.a !PREFIX!\Library\lib\libjaylink-%VERSION%.dll.a > nul
  if errorlevel 1 exit 1

  dlltool -d libjaylink\jaylink.def ^
          --dllname libjaylink.dll ^
          --output-lib libjaylink.dll.a
  if errorlevel 1 exit 1

  copy /Y libjaylink.dll.a !PREFIX!\Library\lib\libjaylink.dll.a > nul
  if errorlevel 1 exit 1

  del !PREFIX!\Library\lib\libjaylink.lib

  echo "Checking symbols in .dll and .dll.a files"
  echo "   nm .dll.a"
  nm !PREFIX!\Library\lib\libjaylink.dll.a | findstr "jaylink_has_cap"
  echo "   objdump -x .dll"
  objdump -x !PREFIX!\Library\bin\libjaylink.dll | findstr "jaylink_has_cap"
  echo "Checking symbols in .dll files"

popd || exit /b 1

echo Creating test program...
echo #include ^<libjaylink/libjaylink.h^> > test.c
echo int main() { >> test.c
echo     int cap = jaylink_has_cap(NULL, 0); >> test.c
echo     return cap; >> test.c
echo } >> test.c

echo Compiling and linking with MSVC...
cl.exe /I%PREFIX%/Library/include test.c /link /LIBPATH:%PREFIX%/Library/lib jaylink.lib
if errorlevel 1 (
    echo Build failed
    exit /b 1
)

conda create -n testenv -c conda-forge -c defaults -c msys2 gcc
echo Compiling and linking with GCC...
$(which gcc) -I%PREFIX%/Library/include test.c -L%PREFIX%/Library/lib -ljaylink
if errorlevel 1 (
    echo Build failed
    exit /b 1
)

echo Compiling and linking with MSVC...
cl.exe /I%PREFIX%/Library/include test.c /link /LIBPATH:%PREFIX%/Library/lib libjaylink.dll.a
if errorlevel 1 (
    echo Build failed
    exit /b 1
)
