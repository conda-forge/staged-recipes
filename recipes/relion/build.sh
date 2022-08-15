export CC=gcc
export CXX=g++

mkdir relion
tar -xvf 3.1.3.tar.gz -C relion

mkdir -p build && cd build
cmake -DGUI=ON -DFORCE_OWN_FLTK=ON ../relion
make -j 24
