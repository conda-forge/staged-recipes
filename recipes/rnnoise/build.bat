@echo off
REM Windows build script for rnnoise using autotools_clang_conda

REM Model files are now extracted directly to src/ directory
REM (no need to copy since target_directory was removed from recipe.yaml)

REM Call the autotools clang conda build wrapper
call "%BUILD_PREFIX%\Library\bin\run_autotools_clang_conda_build.bat" build.sh
if %ERRORLEVEL% neq 0 exit 1
