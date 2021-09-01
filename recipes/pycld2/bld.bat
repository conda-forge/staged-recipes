mkdir build
cd build

set "CFLAGS= -LD"

"%PYTHON%" -m pip install --no-deps --ignore-installed  .
if errorlevel 1 exit 1
