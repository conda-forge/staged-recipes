mkdir build
cd build
cmake .. -G "NMake Makefiles"
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

cd ..
cd python
python setup.py install
if errorlevel 1 exit 1
