export CXXFLAGS="-std=c++98"

mkdir _build && cd _build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release
make all -j$CPU_COUNT
make install
