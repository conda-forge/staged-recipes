echo "EJH - Starting windows build"
SET KITE_ROOT="%cd%"

REM Install KITEx
echo "EJH - Building KITEx"
sed -i.bak '/set(CMAKE_\w\+_COMPILER/d' ./CMakeLists.txt
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=%PREFIX% ..
make -j%CPU_COUNT%
make install

REM Install KITE-tools
echo "EJH - Building KITE-tools"
cd %KITE_ROOT%
cd tools
sed -i.bak '/set(CMAKE_\w\+_COMPILER/d' ./CMakeLists.txt
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=%PREFIX% ..
make -j%CPU_COUNT%
make install

REM Install kite.py package
echo "EJH - Building kite.py"
cd %KITE_ROOT%

PYTHON -m pip install . -vv

