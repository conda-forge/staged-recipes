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

dir %PREFIX%\Lib\site-packages
dir %PREFIX%\Lib\site-packages\%PKG_NAME%*
%PYTHON% -c "import ctypes, glob; dll_path = glob.glob(r'%PREFIX%\Lib\site-packages\ckzg*pyd')[0]; ctypes.CDLL(dll_path)"
