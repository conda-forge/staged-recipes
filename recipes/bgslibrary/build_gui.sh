cd gui/qt
cmake CMakeLists.txt -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_PREFIX_PATH=$PREFIX
cmake --build . --config Release --parallel ${CPU_COUNT}
cp bgslibrary_gui $PREFIX/bin
