mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -DENABLE_PROTOBUF=ON -GNinja
if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1
cd ../python
python setup.py install --single-version-externally-managed --record=record.txt
if errorlevel 1 exit 1
cd ../runtime/python
python setup.py install --single-version-externally-managed --record=record.txt
if errorlevel 1 exit 1
