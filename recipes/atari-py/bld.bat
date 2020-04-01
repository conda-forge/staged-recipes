%PYTHON% pip install cmake pytest
./installzlib.bat
mkdir -p atari_py\ale_interface\build && cd atari_py\ale_interface\build

cmake ^
    -DCMAKE_GENERATOR_PLATFORM=x64 ..
cmake --build .
cp Debug\ale_c.dll ..\
cd ..\..\..\

%PYTHON% pip install wheel && pip wheel . -w wheelhouse --no-deps -vvv
ls wheelhouse\atari_py*
rm -rf atari_py*
%PYTHON% pip install $(ls wheelhouse\atari_py*)
