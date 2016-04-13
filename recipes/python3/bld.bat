set version=3.5.1

if exist %PREFIX%\python3.exe  (
  echo "This is a placeholder file for the python3 package in a python=3 env" > $PREFIX/share/python3_pkg_placeholder
  exit 0
)

REM ========== prepare source

if "%ARCH%"=="64" (
    set DMSW=-DMS_WIN64
) else (
    set DMSW=
)

%REPLACE% "@DMSW@" "%DMSW%" Lib\distutils\cygwinccompiler.py
if errorlevel 1 exit 1

REM ========== actual compile step

vcbuild PCbuild\pcbuild.sln "%RELEASE_TARGET%"

if "%ARCH%"=="64" (
    copy PCbuild\amd64\* PCbuild\
    if errorlevel 1 exit 1
)

REM ========== add stuff from official python.org msi

set MSI_DIR=\Pythons\%version%-%ARCH%
for %%x in (DLLs Doc libs tcl Tools) do (
    xcopy /s %MSI_DIR%\%%x %PREFIX%\%%x\
    if errorlevel 1 exit 1
)
copy %MSI_DIR%\LICENSE.txt %PREFIX%\LICENSE_PYTHON3.txt
if errorlevel 1 exit 1

REM ========== add stuff from our own build

set PCB=%SRC_DIR%\PCbuild

xcopy /s %SRC_DIR%\Include %PREFIX%\include\
if errorlevel 1 exit 1
copy %SRC_DIR%\PC\pyconfig.h %PREFIX%\include\
if errorlevel 1 exit 1

copy %PCB%\python35.dll %PREFIX%
if errorlevel 1 exit 1
copy %PCB%\python.exe %PREFIX%\python3.exe
if errorlevel 1 exit 1
copy %PCB%\python35.dll %PREFIX%\python3w.exe
if errorlevel 1 exit 1

copy %PCB%\python35.lib %PREFIX%\libs\
if errorlevel 1 exit 1
del %PREFIX%\libs\libpython*.a
if errorlevel 1 exit 1

copy %PCB%\w9xpopen.exe %PREFIX%\
if errorlevel 1 exit 1

xcopy /s %SRC_DIR%\Lib %STDLIB_DIR%\
if errorlevel 1 exit 1
rd /s /q %PREFIX%\Lib\test
if errorlevel 1 exit 1

REM ========== bytecode compile standard library

%PREFIX%\python3.exe -Wi %STDLIB_DIR%\compileall.py -f -q -x "bad_coding|badsyntax|py3_" %STDLIB_DIR%
if errorlevel 1 exit 1

REM ========== add idle script

mkdir %SCRIPTS%
if errorlevel 1 exit 1
copy %SRC_DIR%\Tools\scripts\idle %SCRIPTS%\idle3
if errorlevel 1 exit 1
