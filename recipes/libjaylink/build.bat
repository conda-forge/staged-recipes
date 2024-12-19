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

  dumpbin /all build-libjaylink\libjaylink\libjaylink.exp
  powershell -Command "Get-Content libjaylink\libjaylink.h | Select-Object -Skip 450 -First 11"
  dlltool -v -d libjaylink\jaylink.def ^
          --dllname libjaylink-%VERSION%.dll ^
          --as-flags="--defsym __imp_prefix=1" ^
          --add-underscore ^
          --kill-at ^
          --output-lib libjaylink-%VERSION%.dll.a
  if errorlevel 1 exit 1

  copy /Y libjaylink-%VERSION%.dll.a !PREFIX!\Library\lib\libjaylink-%VERSION%.dll.a > nul
  if errorlevel 1 exit 1

  dlltool -v -d libjaylink\jaylink.def ^
          --dllname libjaylink.dll ^
          --as-flags="--defsym __imp_prefix=1" ^
          --add-underscore ^
          --kill-at ^
          --output-lib libjaylink.dll.a
  if errorlevel 1 exit 1

  findstr /v "^;" libjaylink\jaylink.def | findstr /v "^$" > temp.def
  dlltool -v -d temp.def ^
          --dllname libjaylink.dll ^
          --as-flags="--defsym __imp_prefix=1" ^
          --add-underscore ^
          --kill-at ^
          --output-lib libjaylink.dll.a
  if errorlevel 1 exit 1

  copy /Y libjaylink.dll.a !PREFIX!\Library\lib\libjaylink.dll.a > nul
  if errorlevel 1 exit 1

  echo "Checking symbols in .dll and .dll.a files"
  objdump -p !PREFIX!\Library\bin\libjaylink.dll | findstr "has_cap"
  echo "   nm .dll.a"
  nm !PREFIX!\Library\lib\libjaylink.dll.a | findstr "jaylink"
  echo "   objdump -x nm .dll"
  objdump -x !PREFIX!\Library\lib\libjaylink.dll | findstr "jaylink"
  echo "Checking symbols in .dll files"

popd || exit /b 1

echo Creating test program...
echo #include ^<libjaylink/libjaylink.h^> > test.c
echo int main() { >> test.c
echo     int cap = jaylink_has_cap(NULL, 0); >> test.c
echo     return cap; >> test.c
echo } >> test.c

echo Compiling test...
gcc -c test.c -I%PREFIX%/Library/include
if errorlevel 1 (
    echo Compilation failed
    exit /b 1
)

echo Linking test...
gcc -v test.o -L%PREFIX%/Library/lib -ljaylink -o test.exe
if errorlevel 1 (
    echo Linking failed
    exit /b 1
)