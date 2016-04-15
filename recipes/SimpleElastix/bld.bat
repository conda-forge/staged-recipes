mkdir build
cd build
cmake ../SuperBuild
msbuild ALL_BUILD.vcxproj /p:Configuration=Release

cd Wrapping/PythonPackage
"%PYTHON%" setup.py install --single-version-externally-managed --record record.txt
