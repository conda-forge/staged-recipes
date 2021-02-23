mkdir build

make clean
## STATIC builds fail
##STATIC=1 CC="-lm -lc -latomic" make
make

PREFIX="./build" make lite-test

#echo "cp -v ./stress-ng ${PREFIX}/"
#cp -v ./stress-ng ${PREFIX}/
