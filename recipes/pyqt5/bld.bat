:: Note: QtNfc is failing, so we are disabling it for now
%PYTHON% configure.py ^
        --verbose ^
        --confirm-license ^
        --assume-shared ^
        --qmake=%LIBRARY_BIN%\qmake.exe ^
        --bindir=%SCRIPTS% ^
        --spec=win32-msvc%VS_YEAR% ^
        --disable QtNfc
if errorlevel 1 exit 1

jom
if errorlevel 1 exit 1

jom install
if errorlevel 1 exit 1
