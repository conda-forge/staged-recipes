mkdir -p atari_py\ale_interface\build && cd atari_py\ale_interface\build

cd atari_py\ale_interface\build
cmake -G "%CMAKE_GENERATOR%" ^
      -DCMAKE_GENERATOR_PLATFORM=x64 ^
      
cmake --build .

rm -rf atari_py*
%PYTHON% -m pip install . --no-deps -vv
