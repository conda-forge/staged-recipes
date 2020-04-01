%PYTHON% -m pip install cmake pytest
.\installzlib.bat
mkdir -p atari_py\ale_interface\build && cd atari_py\ale_interface\build

cmake -G "NMake Makefiles" ..
      -DCMAKE_GENERATOR_PLATFORM=x64 ..
cmake --build .
cp Debug\ale_c.dll ..\
cd ..\..\..\

rm -rf atari_py*
%PYTHON% -m pip install . --no-deps -vv
