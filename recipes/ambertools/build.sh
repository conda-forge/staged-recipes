ln -s ${CC} ${PREFIX}/bin/gcc
ln -s ${CXX} ${PREFIX}/bin/g++
ln -s ${GFORTRAN} ${PREFIX}/bin/gfortran

echo 'N' | ./configure  -noX11 -norism  --skip-python gnu
# using the -openmp flag causes packages not to be included in the build
# however, the RISM model requires OpenMP, so -norism is set
# the --prefix tag does not work, so copy the files manually to $PREFIX

bash amber.sh

make
make install

mkdir $PREFIX/dat

cp -rf bin/* $PREFIX/bin/
cp -rf dat/* $PREFIX/dat/
cp -rf lib/* $PREFIX/lib/
cp -rf include/* $PREFIX/include/

rm ${PREFIX}/bin/gcc
rm ${PREFIX}/bin/g++
rm ${PREFIX}/bin/gfortran