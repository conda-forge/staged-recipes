@echo off
REM Windows build script for rnnoise using autotools_clang_conda

REM Model files are now extracted directly to src/ directory
REM (no need to copy since target_directory was removed from recipe.yaml)

REM Ensure host environment directories exist to prevent find command errors
if not exist "%PREFIX%\Library\lib" mkdir "%PREFIX%\Library\lib"
if not exist "%PREFIX%\Library\include" mkdir "%PREFIX%\Library\include"
if not exist "%PREFIX%\Library\bin" mkdir "%PREFIX%\Library\bin"

REM Call the autotools clang conda build wrapper
call "%BUILD_PREFIX%\Library\bin\run_autotools_clang_conda_build.bat" build.sh
if %ERRORLEVEL% neq 0 exit 1
