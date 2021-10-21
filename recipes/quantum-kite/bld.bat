echo "EJH - Starting windows build"
echo EJH - Using C compiler %CC% and C++ compiler %CXX%
SET KITE_ROOT="%cd%"

REM Install KITEx
echo EJH - Building KITEx
 
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=%PREFIX% -DCMAKE_MAKE_PROGRAM=make ..
make -j%CPU_COUNT%
make install

REM Install KITE-tools
echo "EJH - Building KITE-tools"
cd %KITE_ROOT%
cd tools
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=%PREFIX% -DCMAKE_MAKE_PROGRAM=make ..
make -j%CPU_COUNT%
make install

REM Install kite.py package
echo "EJH - Building kite.py"
cd %KITE_ROOT%

PYTHON -m pip install . -vv

