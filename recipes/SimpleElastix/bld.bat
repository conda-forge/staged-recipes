mkdir build
cd build
cmake ../SuperBuild -LAH -G "NMake Makefiles"
cmake --build . --target INSTALL --config Release

"%PYTHON%" ./SimpleITK-build/Wrapping/PythonPackage/setup.py install --single-version-externally-managed --record record.txt
