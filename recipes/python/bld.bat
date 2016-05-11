REM brand Python
python %RECIPE_DIR%\brand_python.py
if errorlevel 1 exit 1

mkdir %PREFIX%\Doc
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://www.python.org/ftp/python/3.5.1/python351.chm', 'python351.chm')"
copy /Y %SRC_DIR%\python351.chm %PREFIX%\Doc\
if errorlevel 1 exit 1

REM ========== actual compile step
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
copy /Y %SRC_DIR%\PC\py.ico %PREFIX%\DLLs\
if errorlevel 1 exit 1
copy /Y %SRC_DIR%\PC\pyc.ico %PREFIX%\DLLs\
if errorlevel 1 exit 1

REM Copy Tools subdirectories
mkdir %PREFIX%\Tools
xcopy /s /y /i %SRC_DIR%\Tools\demo %PREFIX%\demo
if errorlevel 1 exit 1
xcopy /s /y /i %SRC_DIR%\Tools\i18n %PREFIX%\i18n
if errorlevel 1 exit 1
xcopy /s /y /i %SRC_DIR%\Tools\parser %PREFIX%\parser
if errorlevel 1 exit 1
xcopy /s /y /i %SRC_DIR%\Tools\pynche %PREFIX%\pynche
if errorlevel 1 exit 1
xcopy /s /y /i %SRC_DIR%\Tools\scripts %PREFIX%\scripts
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

mkdir %PREFIX%\libs
copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\python35.lib %PREFIX%\libs\
if errorlevel 1 exit 1

del %PREFIX%\libs\libpython*.a

xcopy /s /y %SRC_DIR%\Lib %PREFIX%\Lib\
if errorlevel 1 exit 1

REM ========== bytecode compile standard library

rd /s /q %STDLIB_DIR%\lib2to3\tests\
if errorlevel 1 exit 1

%PYTHON% -Wi %STDLIB_DIR%\compileall.py -f -q -x "bad_coding|badsyntax|py2_" %STDLIB_DIR%
if errorlevel 1 exit 1

REM ========== add scripts

IF NOT exist %SCRIPTS% (mkdir %SCRIPTS%)
if errorlevel 1 exit 1

for %%x in (idle pydoc) do (
    copy /Y %SRC_DIR%\Tools\scripts\%%x3 %SCRIPTS%\%%x
    if errorlevel 1 exit 1
)

copy /Y %SRC_DIR%\Tools\scripts\2to3 %SCRIPTS%
if errorlevel 1 exit 1
