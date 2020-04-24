@echo on

cd "win32"

set "PREFIX=%LIBRARY_PREFIX%"
set "PYTHON=%BUILD_PREFIX%\python.exe"

md "%LIBRARY_PREFIX%\share\icons\Adwaita"

nmake /F adwaita-msvc.mak
if errorlevel 1 exit 1

nmake /F adwaita-msvc.mak install
if errorlevel 1 exit 1
