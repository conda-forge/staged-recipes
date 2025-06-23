@echo on

@REM Create conda.rb from default and switch to full-core
copy /Y build_config\default.rb build_config\conda.rb
if errorlevel 1 exit 1
sed -i "s|conf.gembox 'default'|conf.gembox 'full-core'|" build_config\conda.rb
if errorlevel 1 exit 1

@REM Export MRUBY_CONFIG for the build
set "MRUBY_CONFIG=build_config\conda.rb"
if errorlevel 1 exit 1

@REM Use it as LD so -Wl, options are handled by the compiler driver
set "LD=%CC%"
if errorlevel 1 exit 1

@REM Run build and tests (use ruby -S rake to ensure using the Ruby in PATH)
ruby -S rake all test
if errorlevel 1 exit 1

mkdir "%PREFIX%\lib" 2>nul
if errorlevel 1 exit 1
copy /Y build\host\lib\*.a "%PREFIX%\lib\" 2>nul
if errorlevel 1 exit 1

mkdir "%PREFIX%\bin" 2>nul
if errorlevel 1 exit 1
copy /Y build\host\bin\* "%PREFIX%\bin\" 2>nul
if errorlevel 1 exit 1

mkdir "%PREFIX%\mrbgems" 2>nul
if errorlevel 1 exit 1
mkdir "%PREFIX%\mrblib" 2>nul
if errorlevel 1 exit 1
mkdir "%PREFIX%\include" 2>nul
if errorlevel 1 exit 1
xcopy /E /I /Y build\host\mrbgems "%PREFIX%\mrbgems" >nul 2>nul
if errorlevel 1 exit 1
xcopy /E /I /Y build\host\mrblib "%PREFIX%\mrblib" >nul 2>nul
if errorlevel 1 exit 1
xcopy /E /I /Y include "%PREFIX%\include" >nul 2>nul
if errorlevel 1 exit 1
