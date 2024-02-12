REM Specifying the XEUS_PYTHONHOME_RELPATH to the general prefix.

cmake -G "NMake Makefiles" ^
  -D CMAKE_BUILD_TYPE=Release ^
  -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -D PYTHON_EXECUTABLE=%PYTHON% ^
  -D XEUS_PYTHONHOME_RELPATH=..\\ ^
  %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1

REM Copying kernelspec to the general prefix for Jupyter to pick it up.

md %PREFIX%\share\jupyter\kernels\xpython
xcopy %LIBRARY_PREFIX%\share\jupyter\kernels\xpython %PREFIX%\share\jupyter\kernels\xpython /F /Y
md %PREFIX%\share\jupyter\kernels\xpython-raw
xcopy %LIBRARY_PREFIX%\share\jupyter\kernels\xpython-raw %PREFIX%\share\jupyter\kernels\xpython-raw /F /Y
