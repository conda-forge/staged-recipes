
make clean
## do static build
##STATIC=1 CC="-lm -lc -latomic" make
make

make lite-test

##find ./ -type f -name "stress-ng"
##cp -v ./stress-ng ${PATH}/
echo "cp -v ./stress-ng ${PREFIX}/"
cp -v ./stress-ng ${PREFIX}/
# echo "cp -v ./stress-ng ${BUILD_PREFIX}/"
# cp -v ./stress-ng ${BUILD_PREFIX}/
