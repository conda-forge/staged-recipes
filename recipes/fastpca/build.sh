mkdir build && cd build
cmake ..
make

cp -r src/ ${PREFIX}
rm -rf ${PREFIX}/CMakeFiles

mkdir ${PREFIX}/bin
ln -s ${PREFIX}/src/fastpca ${PREFIX}/bin/fastpca