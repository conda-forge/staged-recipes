
mpifort=$(which mpifort)
mv $mpifort $mpifort.orig
sed 's/\(enable_wrapper_rpath=\)"yes"/\1"no"/' $mpifort.orig >$mpifort
chmod +x $mpifort

echo ${SP_DIR}

#test python building
mkdir ${SP_DIR}/paraprobe_autoreporter
cp -rf paraprobe-toolbox/code/paraprobe-autoreporter/src/python/* ${SP_DIR}/paraprobe_autoreporter

mkdir ${SP_DIR}/paraprobe_parmsetup
cp -rf paraprobe-toolbox/code/paraprobe-parmsetup/src/python/* ${SP_DIR}/paraprobe_parmsetup
	
mkdir ${SP_DIR}/paraprobe_transcoder
cp -rf paraprobe-toolbox/code/paraprobe-transcoder/src/python/* ${SP_DIR}/paraprobe_transcoder

cp paraprobe-toolbox/code/thirdparty/mandatory/voroxx/voro++-0.4.6.tar.xz .
tar xvf voro++-0.4.6.tar.xz
mv voro++-0.4.6 voro++


cd paraprobe-toolbox
cd code

cd paraprobe-utils
cp ../thirdparty/mandatory/hdf5cxxwrapper/src/cxx/* src/cxx/
cp ../../../voro++/src/* src/cxx/
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=mpicxx -DCONDA_PREFIX=${PREFIX} .
make
ls
cd ..

mkdir compiled_code
#cp paraprobe-utils/CMakeFiles/paraprobe-utils.dir${SRC_DIR}/paraprobe-toolbox/code/paraprobe-utils/src/cxx/* compiled_code/
cp paraprobe-utils/CMakeFiles/paraprobe-utils.dir/src/cxx/* compiled_code/

cd paraprobe-ranger
export CXXFLAGS="$CXXFLAGS -DBOOST_ERROR_CODE_HEADER_ONLY"
cmake -D Boost_NO_BOOST_CMAKE=ON \
	  -D CMAKE_BUILD_TYPE=Release \
	  -D CMAKE_CXX_COMPILER=mpicxx \
	  -D CONDA_PREFIX=${PREFIX} .
make
cp paraprobe_ranger ${PREFIX}/bin/
cd ..

mv $mpifort.orig $mpifort