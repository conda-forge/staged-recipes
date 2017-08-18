:: Write python configuration, see https://github.com/boostorg/build/issues/194
@echo using python > user-config.jam
@echo : %PY_VER% >> user-config.jam
@echo : %PYTHON:\=\\% >> user-config.jam
@echo : %PREFIX:\=\\%\\include >> user-config.jam
@echo : %PREFIX:\=\\%\\libs >> user-config.jam
@echo ; >> user-config.jam
xcopy user-config.jam C:\Users\appveyor

:: Start with bootstrap
call bootstrap.bat
if errorlevel 1 exit 1

:: Build step
.\b2 install ^
    --build-dir=buildboost ^
    --prefix=%LIBRARY_PREFIX% ^
    toolset=msvc-%VS_MAJOR%.0 ^
    address-model=%ARCH% ^
    variant=release ^
    threading=multi ^
    link=static,shared ^
    --with-python ^
    -j%CPU_COUNT%
if errorlevel 1 exit 1

:: Get the major minor version info (e.g. `1_61`)
python -c "import os; print('_'.join(os.environ['PKG_VERSION'].split('.')[:2]))" > temp.txt
set /p MAJ_MIN_VER=<temp.txt

:: Install fix-up for a non version-specific boost include
xcopy /E/Y %LIBRARY_INC%\boost-%MAJ_MIN_VER%\boost\* %LIBRARY_INC%\boost\
rmdir /s /q %LIBRARY_INC%\boost-%MAJ_MIN_VER%\boost

:: Move dll's to LIBRARY_BIN
move %LIBRARY_LIB%\*vc%VS_MAJOR%0-mt-%MAJ_MIN_VER%.dll "%LIBRARY_BIN%"
if errorlevel 1 exit 1

