ReM ========== actual compile step

if "%ARCH%"=="64" (
   set PLATFORM=x64
   set VC_PATH=x64
   set BUILD_PATH=amd64
) else (
   set PLATFORM=Win32
   set VC_PATH=x86
   set BUILD_PATH=win32
)


cd PCbuild
call build.bat -e -p %PLATFORM%
if errorlevel 1 exit 1
cd ..

mkdir %PREFIX%\DLLs
xcopy /s /y %SRC_DIR%\PCBuild\%BUILD_PATH%\*.pyd %PREFIX%\DLLs\
if errorlevel 1 exit 1
copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\sqlite3.dll %PREFIX%\DLLs\
if errorlevel 1 exit 1
copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\tcl86t.dll %PREFIX%\DLLs\
if errorlevel 1 exit 1
copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\tk86t.dll %PREFIX%\DLLs\
if errorlevel 1 exit 1


REM ========== add stuff from official python.org installer

REM set MSI_DIR=\Pythons\3.5.0-%ARCH%
REM for %%x in (DLLs Doc libs tcl Tools) do (
REM     xcopy /s /y %MSI_DIR%\%%x %PREFIX%\%%x\
REM     if errorlevel 1 exit 1
REM )

copy %SRC_DIR%\LICENSE %PREFIX%\LICENSE_PYTHON.txt
if errorlevel 1 exit 1

REM ========== add stuff from our own build

xcopy /s /y %SRC_DIR%\Include %PREFIX%\include\
if errorlevel 1 exit 1

copy /Y %SRC_DIR%\PC\pyconfig.h %PREFIX%\include\
if errorlevel 1 exit 1

for %%x in (python35.dll python.exe pythonw.exe) do (
    copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\%%x %PREFIX%
    if errorlevel 1 exit 1
)
REM copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\python35.lib %PREFIX%\libs\
REM if errorlevel 1 exit 1

del %PREFIX%\libs\libpython*.a

xcopy /s /y %SRC_DIR%\Lib %PREFIX%\Lib\
if errorlevel 1 exit 1

REM ========== add MS VC runtime dlls
REM ========== REQUIRES Win 10 SDK be installed, or files otherwise copied to location below!

xcopy /s /y "C:\Program Files (x86)\Windows Kits\10\Redist\ucrt\DLLs\%VC_PATH%\*" %PREFIX%\

REM ========== This one comes from visual studio
xcopy /s /y "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\redist\%VC_PATH%\Microsoft.VC140.CRT\*.dll" %PREFIX%\

REM ========== bytecode compile standard library

rd /s /q %STDLIB_DIR%\lib2to3\tests\
if errorlevel 1 exit 1

REM %PYTHON% -Wi %STDLIB_DIR%\compileall.py -f -q -x "bad_coding|badsyntax|py2_" %STDLIB_DIR%
REM if errorlevel 1 exit 1

REM ========== add scripts

IF NOT exist %SCRIPTS% (mkdir %SCRIPTS%)
if errorlevel 1 exit 1

for %%x in (idle pydoc) do (
    copy /Y %SRC_DIR%\Tools\scripts\%%x3 %SCRIPTS%\%%x
    if errorlevel 1 exit 1
)

copy /Y %SRC_DIR%\Tools\scripts\2to3 %SCRIPTS%
if errorlevel 1 exit 1
