@echo off

setlocal EnableDelayedExpansion

:: Determine Qt Major verion (4 or 5)
for /f "tokens=4" %%i in ('%LIBRARY_BIN%\qmake -v ^| find "Qt version"') do (
	set QT_MAJOR_VER=%%i
	set QT_MAJOR_VER=!QT_MAJOR_VER:~0,1!
)
if [!QT_MAJOR_VER!] == [] Exit /B 1

:: %PYTHON% -c "import PyQt!QT_MAJOR_VER!.Qsci"
python -c "import PyQt!QT_MAJOR_VER!.Qsci"