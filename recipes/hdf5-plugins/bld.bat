mkdir build
cd build
cmake .. -DENABLE_BITSHUFFLE_PLUGIN=yes -DENABLE_LZ4_PLUGIN=yes -DENABLE_BZIP2_PLUGIN=yes -DCMAKE_INSTALL_PREFIX=$PREFIX -G"Visual Studio %VS_MAJOR% %VS_YEAR% Win64"
cmake --build . --target INSTALL
