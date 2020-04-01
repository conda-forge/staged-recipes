mkdir -p atari_py/ale_interface/build

cd atari_py/ale_interface/build
cmake -DCMAKE_GENERATOR_PLATFORM=x64 ..
cmake --build .
cp Debug/ale_c.dll ../
cd ../../../

ls wheelhouse/atari_py*
rm -rf atari_py*
%PYTHON% pip install $(ls wheelhouse/atari_py*)
