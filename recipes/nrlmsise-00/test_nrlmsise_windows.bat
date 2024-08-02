@echo off

REM Compile the test executable
cl /c /O2 /nologo /EHsc /I%PREFIX%\Library\include nrlmsise-00_test.c
if errorlevel 1 (
  echo Compilation failed
  exit /b 1
)
link /OUT:nrlmsise-00_test.exe nrlmsise-00_test.obj /LIBPATH:%PREFIX%\Library\lib nrlmsise-00.lib
if errorlevel 1 (
  echo Linking failed
  exit /b 1
)

REM Execute the test executable
if not exist nrlmsise-00_test.exe (
  echo Test executable not found
  exit /b 1
)
nrlmsise-00_test.exe
if errorlevel 1 (
  echo Test execution failed
  exit /b 1
)
echo Test execution succeeded
