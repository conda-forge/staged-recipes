call %BUILD_PREFIX%\Library\bin\run_autotools_clang_conda_build.bat build-lib.sh
if %ERRORLEVEL% neq 0 exit 1
