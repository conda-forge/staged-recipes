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

copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\python.pdb %PREFIX%\
if errorlevel 1 exit 1
copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\python35.pdb %PREFIX%\
if errorlevel 1 exit 1
copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\pythonw.pdb %PREFIX%\
if errorlevel 1 exit 1

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

copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\_ctypes_test.pdb %PREFIX%\DLLs\
if errorlevel 1 exit 1
copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\_testbuffer.pdb %PREFIX%\DLLs\
if errorlevel 1 exit 1
copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\_testcapi.pdb %PREFIX%\DLLs\
if errorlevel 1 exit 1
copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\_testimportmultiple.pdb %PREFIX%\DLLs\
if errorlevel 1 exit 1
copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\_testmultiphase.pdb %PREFIX%\DLLs\
if errorlevel 1 exit 1
copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\_tkinter.pdb %PREFIX%\DLLs\
if errorlevel 1 exit 1
copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\sqlite3.pdb %PREFIX%\DLLs\
if errorlevel 1 exit 1

REM Copy Tools subdirectories
mkdir %PREFIX%\Tools
xcopy /s /y /i %SRC_DIR%\Tools\demo %PREFIX%\Tools\demo
if errorlevel 1 exit 1
xcopy /s /y /i %SRC_DIR%\Tools\i18n %PREFIX%\Tools\i18n
if errorlevel 1 exit 1
xcopy /s /y /i %SRC_DIR%\Tools\parser %PREFIX%\Tools\parser
if errorlevel 1 exit 1
xcopy /s /y /i %SRC_DIR%\Tools\pynche %PREFIX%\Tools\pynche
if errorlevel 1 exit 1
xcopy /s /y /i %SRC_DIR%\Tools\scripts %PREFIX%\Tools\scripts
if errorlevel 1 exit 1

del %PREFIX%\Tools\demo\README
if errorlevel 1 exit 1
del %PREFIX%\Tools\pynche\README
if errorlevel 1 exit 1
del %PREFIX%\Tools\pynche\pynche
if errorlevel 1 exit 1
del %PREFIX%\Tools\scripts\README
if errorlevel 1 exit 1
del %PREFIX%\Tools\scripts\dutree.doc
if errorlevel 1 exit 1
del %PREFIX%\Tools\scripts\idle3
if errorlevel 1 exit 1

move /y %PREFIX%\Tools\scripts\2to3 %PREFIX%\Tools\scripts\2to3.py
if errorlevel 1 exit 1
move /y %PREFIX%\Tools\scripts\pydoc3 %PREFIX%\Tools\scripts\pydoc3.py
if errorlevel 1 exit 1
move /y %PREFIX%\Tools\scripts\pyvenv %PREFIX%\Tools\scripts\pyvenv.py
if errorlevel 1 exit 1

REM Copy tcl directory
xcopy /s /y /i %SRC_DIR%\externals\tcltk64\lib %PREFIX%\tcl
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
copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\python3.lib %PREFIX%\libs\
if errorlevel 1 exit 1
copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\_tkinter.lib %PREFIX%\libs\
if errorlevel 1 exit 1

del %PREFIX%\libs\libpython*.a

xcopy /s /y %SRC_DIR%\Lib %PREFIX%\Lib\
if errorlevel 1 exit 1

REM ========== bytecode compile standard library

rd /s /q %STDLIB_DIR%\lib2to3\tests\
if errorlevel 1 exit 1

%PYTHON% -Wi %STDLIB_DIR%\compileall.py -f -q -x "bad_coding|badsyntax|py2_" %STDLIB_DIR%
if errorlevel 1 exit 1

REM Pickle lib2to3 Grammar
%PYTHON% -m lib2to3 --help

REM ========== add scripts

IF NOT exist %SCRIPTS% (mkdir %SCRIPTS%)
if errorlevel 1 exit 1

for %%x in (idle pydoc) do (
    copy /Y %SRC_DIR%\Tools\scripts\%%x3 %SCRIPTS%\%%x
    if errorlevel 1 exit 1
)

copy /Y %SRC_DIR%\Tools\scripts\2to3 %SCRIPTS%
if errorlevel 1 exit 1
