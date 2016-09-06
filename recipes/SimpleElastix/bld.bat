mkdir build
cd build
cmake ../SuperBuild
msbuild ALL_BUILD.vcxproj

"%PYTHON%" ./SimpleITK-build/Wrapping/PythonPackage/setup.py install --single-version-externally-managed --record record.txt
