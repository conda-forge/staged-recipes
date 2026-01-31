@echo on

@REM Create conda.rb from default and switch to full-core
copy /Y build_config\default.rb build_config\conda.rb
if errorlevel 1 exit 1
sed -i "s|conf.toolchain|conf.toolchain :visualcpp|" build_config\conda.rb
if errorlevel 1 exit 1
sed -i "s|conf.gembox 'default'|conf.gembox 'full-core'|" build_config\conda.rb
if errorlevel 1 exit 1

@REM Export MRUBY_CONFIG for the build
set "MRUBY_CONFIG=build_config\conda.rb"
if errorlevel 1 exit 1

@REM Run build and tests (use ruby -S rake to ensure using the Ruby in PATH)
ruby -S rake all test
if errorlevel 1 exit 1

mkdir "%LIBRARY_PREFIX%\lib"
if errorlevel 1 exit 1
copy /Y build\host\lib\*.lib "%LIBRARY_PREFIX%\lib\"
if errorlevel 1 exit 1

mkdir "%LIBRARY_PREFIX%\bin"
if errorlevel 1 exit 1
copy /Y bin\*.exe "%LIBRARY_PREFIX%\bin\"
if errorlevel 1 exit 1

mkdir "%LIBRARY_PREFIX%\mrbgems"
if errorlevel 1 exit 1
mkdir "%LIBRARY_PREFIX%\mrblib"
if errorlevel 1 exit 1
mkdir "%LIBRARY_PREFIX%\include"
if errorlevel 1 exit 1
xcopy /E /I /Y build\host\mrbgems "%LIBRARY_PREFIX%\mrbgems"
if errorlevel 1 exit 1
xcopy /E /I /Y build\host\mrblib "%LIBRARY_PREFIX%\mrblib"
if errorlevel 1 exit 1
xcopy /E /I /Y include "%LIBRARY_PREFIX%\include"
if errorlevel 1 exit 1
