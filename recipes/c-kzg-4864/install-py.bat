@echo off

:: Find exact wheel file name
for /f "delims=" %%i in ('dir /b %SRC_DIR%\wheels\%PKG_NAME%-%PKG_VERSION%-*.whl') do set "WHEELS_NAME=%%i"

%PYTHON% -m pip install %SRC_DIR%\wheels\%WHEELS_NAME% ^
--no-build-isolation ^
--no-deps ^
--only-binary :all: ^
--prefix "%PREFIX%"
if errorlevel 1 exit 1
