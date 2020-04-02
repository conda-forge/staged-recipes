mkdir -p atari_py\ale_interface\build && cd atari_py\ale_interface\build

cmake -DCMAKE_GENERATOR_PLATFORM=x64 ..
cmake --build .

%PYTHON% -m pip install wheel && pip wheel . -w wheelhouse --no-deps -vvv
ls wheelhouse\atari_py*
rm -rf atari_py*
%PYTHON% -m pip install $(ls wheelhouse\atari_py*)
