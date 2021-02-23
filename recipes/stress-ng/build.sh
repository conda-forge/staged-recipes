
make clean
make

make lite-test

##find ./ -type f -name "stress-ng"
cp -v ./stress-ng ${PATH}/
cp -v ./stress-ng ${PREFIX}/
cp -v ./stress-ng ${BUILD_PREFIX}/