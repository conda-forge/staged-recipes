REM brand Python with conda-forge startup message
python %RECIPE_DIR%\brand_python.py
if errorlevel 1 exit 1


REM Compile python, extensions and external libraries
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
call build.bat -e -p %PLATFORM% -d
if errorlevel 1 exit 1
cd ..


REM Populate the root package directory
for %%x in (python35.dll python.exe pythonw.exe) do (
    copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\%%x %PREFIX%
    if errorlevel 1 exit 1
)

for %%x in (python.pdb python35.pdb pythonw.pdb) do (
    copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\%%x %PREFIX%
    if errorlevel 1 exit 1
)

copy %SRC_DIR%\LICENSE %PREFIX%\LICENSE_PYTHON.txt
if errorlevel 1 exit 1


REM Populate the DLLs directory
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


REM Populate the Tools directory
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


REM Populate the tcl directory
if "%ARCH%"=="64" (
   xcopy /s /y /i %SRC_DIR%\externals\tcltk64\lib %PREFIX%\tcl
   if errorlevel 1 exit 1
) else (
   xcopy /s /y /i %SRC_DIR%\externals\tcltk\lib %PREFIX%\tcl
   if errorlevel 1 exit 1
)


REM Populate the include directory
xcopy /s /y %SRC_DIR%\Include %PREFIX%\include\
if errorlevel 1 exit 1

copy /Y %SRC_DIR%\PC\pyconfig.h %PREFIX%\include\
if errorlevel 1 exit 1


REM Populate the Scripts directory
IF NOT exist %SCRIPTS% (mkdir %SCRIPTS%)
if errorlevel 1 exit 1

for %%x in (idle pydoc) do (
    copy /Y %SRC_DIR%\Tools\scripts\%%x3 %SCRIPTS%\%%x
    if errorlevel 1 exit 1
)

copy /Y %SRC_DIR%\Tools\scripts\2to3 %SCRIPTS%
if errorlevel 1 exit 1


REM Populate the libs directory
mkdir %PREFIX%\libs
copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\python35.lib %PREFIX%\libs\
if errorlevel 1 exit 1
copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\python3.lib %PREFIX%\libs\
if errorlevel 1 exit 1
copy /Y %SRC_DIR%\PCbuild\%BUILD_PATH%\_tkinter.lib %PREFIX%\libs\
if errorlevel 1 exit 1


REM Populate the Lib directory
del %PREFIX%\libs\libpython*.a
xcopy /s /y %SRC_DIR%\Lib %PREFIX%\Lib\
if errorlevel 1 exit 1


REM bytecode compile the standard library

rd /s /q %STDLIB_DIR%\lib2to3\tests\
if errorlevel 1 exit 1

%PYTHON% -Wi %STDLIB_DIR%\compileall.py -f -q -x "bad_coding|badsyntax|py2_" %STDLIB_DIR%
if errorlevel 1 exit 1


REM Pickle lib2to3 Grammar
%PYTHON% -m lib2to3 --help
