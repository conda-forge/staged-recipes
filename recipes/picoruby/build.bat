@echo on

set "MRUBY_CONFIG=%SRC_DIR%\build_config\default.rb"
if errorlevel 1 exit 1

sed -i "s|conf.toolchain|conf.toolchain :visualcpp|" build_config\default.rb
if errorlevel 1 exit 1

rake
if errorlevel 1 exit 1

if if not exist "%LIBRARY_PREFIX%\bin" mkdir "%LIBRARY_PREFIX%\bin"
if errorlevel 1 exit 1

if if not exist "%LIBRARY_PREFIX%\lib" mkdir "%LIBRARY_PREFIX%\lib"
if errorlevel 1 exit 1

if if not exist "%LIBRARY_PREFIX%\include" mkdir "%LIBRARY_PREFIX%\include"
if errorlevel 1 exit 1

copy /Y bin\*.exe "%LIBRARY_PREFIX%\bin\"
if errorlevel 1 exit 1

copy /Y build\host\lib\*.lib "%LIBRARY_PREFIX%\lib\"
if errorlevel 1 exit 1

if exist "include" (
  xcopy /E /I /Y include "%LIBRARY_PREFIX%\include"
  if errorlevel 1 exit 1
)
