setlocal enableextensions enabledelayedexpansion

set LIBRARY_PATHS=-I %LIBRARY_INC%

pushd %LIBRARY_INC%
for /F "usebackq delims=" %%F in (`dir /b /ad-h`) do (
    set LIBRARY_PATHS=!LIBRARY_PATHS! -I %LIBRARY_INC%\%%F
)
popd
endlocal

set PATH=%cd%\jom;%PATH%
SET PATH=%cd%\qtbase\bin;%_ROOT%\gnuwin32\bin;%PATH%


mklink /D %cd%\angle %cd%\qtbase\src\3rdparty\angle
set ANGLE_DIR=%cd%\angle


mkdir b
pushd b

where jom

call "../configure" -prefix %LIBRARY_PREFIX% ^
-libdir %LIBRARY_LIB% ^
-bindir %LIBRARY_BIN% ^
-headerdir %LIBRARY_INC%/qt ^
-archdatadir %LIBRARY_PREFIX% ^
-datadir %LIBRARY_PREFIX% ^
%LIBRARY_PATHS% ^
-L %LIBRARY_LIB% ^
-L %LIBRARY_BIN% ^
-opensource ^
-release ^
-nomake examples ^
-nomake tests ^
-skip qtwebengine ^
-confirm-license ^
-opengl dynamic ^
-system-libjpeg ^
-system-libpng ^
-system-zlib

echo on

dir && ^
jom && ^
jom install
