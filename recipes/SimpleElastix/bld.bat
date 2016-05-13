mkdir build
cd build
cmake ../SuperBuild -G %CMAKE_GENERATOR%
msbuild ALL_BUILD.vcxproj

"%PYTHON%" ./SimpleITK-build/Wrapping/PythonPackage/setup.py install --single-version-externally-managed --record record.txt
