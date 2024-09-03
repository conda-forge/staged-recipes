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

%PYTHON% -c "import psfile, glob; dll_path = glob.glob(r'%PREFIX%\Lib\site-packages\ckzg*pyd')[0]; pe = pefile.PE(dll_path); print([entry.dll.decode('utf-8') for entry in pe.DIRECTORY_ENTRY_IMPORT])"
%PYTHON% -c "import ctypes, glob; dll_path = glob.glob(r'%PREFIX%\Lib\site-packages\ckzg*pyd')[0]; ctypes.CDLL(dll_path)"
