mkdir build

make clean
## STATIC builds fail
##STATIC=1 CC="-lm -lc -latomic" make
make

export DESTDIR="bin"
#make lite-test

make install

#echo "cp -v ./stress-ng ${PREFIX}/"
#cp -v ./stress-ng ${PREFIX}/
