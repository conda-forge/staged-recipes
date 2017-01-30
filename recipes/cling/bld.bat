mkdir build
cd build
cmake -G "NMake Makefiles" -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -D CMAKE_BUILD_TYPE=Release %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1

REM Install kernelspec
cd %SRC_DIR%\share\cling\Jupyter\kernel\
python %SRC_DIR%\share\cling\Jupyter\kernel\setup.py install
jupyter kernelspec install %PREFIX%\share\cling\Jupyter\kernel\cling-c++11 --sys-prefix
jupyter kernelspec install %PREFIX%\share\cling\Jupyter\kernel\cling-c++14 --sys-prefix
jupyter kernelspec install %PREFIX%\share\cling\Jupyter\kernel\cling-c++17 --sys-prefix
