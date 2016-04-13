mkdir build
cd build
cmake ../SimpleElastix/SuperBuild
msbuild ALL_BUILD.vcxproj /m /p:Configuration=Release

cd Wrapping/PythonPackage
"%PYTHON%" setup.py install --single-version-externally-managed --record record.txt
