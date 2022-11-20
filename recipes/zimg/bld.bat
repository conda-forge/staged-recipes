call %BUILD_PREFIX%\Library\bin\run_autotools_clang_conda_build.bat
if errorlevel 1 exit 1

del %LIBRARY_LIB%\libzimg.a
if errorlevel 1 exit 1
