
echo ${SP_DIR}

#test python building
mkdir ${SP_DIR}/paraprobe_autoreporter
cp -rf paraprobe-toolbox/code/paraprobe-autoreporter/src/python/* ${SP_DIR}/paraprobe_autoreporter

mkdir ${SP_DIR}/paraprobe_parmsetup
cp -rf paraprobe-toolbox/code/paraprobe-parmsetup/src/python/* ${SP_DIR}/paraprobe_parmsetup
	
mkdir ${SP_DIR}/paraprobe_transcoder
cp -rf paraprobe-toolbox/code/paraprobe-transcoder/src/python/* ${SP_DIR}/paraprobe_transcoder


cd paraprobe-toolbox
cd code
cd paraprobe-utils

cp ../code/thirdparty/mandatory/hdf5cxxwrapper/src/cxx/* src/cxx/
cp ../../voro++/src/* src/cxx/
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=mpicxx -DCONDA_PREFIX=${PREFIX} .
make
cd ..

mkdir compiled_code
cp paraprobe-utils/CMakeFiles/paraprobe-utils.dir${SRC_DIR}/paraprobe-toolbox/code/paraprobe-utils/src/cxx/* compiled_code/


cd paraprobe-ranger
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=mpicxx -DCONDA_PREFIX=${PREFIX} .
make
cp paraprobe_ranger ${PREFIX}/bin/
cd ..


