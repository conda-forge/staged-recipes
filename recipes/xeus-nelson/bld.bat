REM Specifying the XEUS_PYTHONHOME_RELPATH to the general prefix.

cmake -GNinja ^
  -D CMAKE_BUILD_TYPE=Release ^
  -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  %SRC_DIR%
if errorlevel 1 exit 1

ninja
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1

REM Copying kernelspec to the general prefix for Jupyter to pick it up.

md %PREFIX%\share\jupyter\kernels\xnelson
xcopy %LIBRARY_PREFIX%\share\jupyter\kernels\xnelson %PREFIX%\share\jupyter\kernels\xnelson /F /Y
