@echo off

:: Find exact wheel file name
for /f "delims=" %%i in ('dir /b %SRC_DIR%\wheels\%PKG_NAME%-%PKG_VERSION%-*.whl') do set "WHEELS_NAME=%%i"

%PYTHON% -m pip install %SRC_DIR%\wheels\%WHEELS_NAME% ^
    --no-build-isolation ^
    --no-deps ^
    --only-binary :all: ^
    -vvv ^
    --prefix "%PREFIX%"
if errorlevel 1 exit 1

:: Prepare post-install test
setlocal enabledelayedexpansion
set "file_path=%SRC_DIR%\bindings\python\tests.py"
set "temp_file=%file_path%.tmp"
(for /f "delims=" %%i in ('type "%file_path%"') do (
    set "line=%%i"
    set "line=!line:/=\!"
    echo !line!
)) > "%temp_file%"
move /y "%temp_file%" "%file_path%"
endlocal
