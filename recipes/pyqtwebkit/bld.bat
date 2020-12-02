%PYTHON% configure.py ^
        --verbose ^
        --confirm-license ^
        --assume-shared ^
        --qmake="%LIBRARY_BIN%\qmake.exe" ^
        --bindir="%LIBRARY_BIN%" ^
        --spec=win32-msvc ^
        --disable QtNfc ^
        --enable QtWebKit ^
        --enable QtWebKitWidgets ^
        --no-designer-plugin ^
        --no-python-dbus ^
        --no-qml-plugin ^
        --no-qsci-api ^
        --no-sip-files ^
        --no-tools

if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
