# build SMS++
rmdir /S smspp-project
git clone -b develop --recurse-submodules https://gitlab.com/smspp/smspp-project.git

cd smspp-project
mkdir build
cd build
cmake %CMAKE_ARGS% -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --config Release -j%CPU_COUNT%
cmake --install . --config Release --prefix "$PREFIX"
