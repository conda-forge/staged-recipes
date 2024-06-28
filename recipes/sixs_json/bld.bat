set FFLAGS="-ffpe-summary=none"

set PATH=%PATH:C:\Program Files\Git\usr\bin;=%

:: Configure.
cmake -G "MSYS Makefiles" -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
make
if errorlevel 1 exit 1

:: Install.
make install
if errorlevel 1 exit 1

%PYTHON% -m pip install .