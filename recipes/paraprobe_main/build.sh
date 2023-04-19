
mpifort=$(which mpifort)
mv $mpifort $mpifort.orig
sed 's/\(enable_wrapper_rpath=\)"yes"/\1"no"/' $mpifort.orig >$mpifort
chmod +x $mpifort

echo ${SP_DIR}
export Boost_ROOT=$PREFIX

#test python building
mkdir ${SP_DIR}/paraprobe_autoreporter
cp -rf paraprobe-toolbox/code/paraprobe-autoreporter/src/python/* ${SP_DIR}/paraprobe_autoreporter

mkdir ${SP_DIR}/paraprobe_parmsetup
cp -rf paraprobe-toolbox/code/paraprobe-parmsetup/src/python/* ${SP_DIR}/paraprobe_parmsetup
cp -rf paraprobe-toolbox/code/paraprobe-parmsetup/src/python/tools/utils* ${SP_DIR}/paraprobe_parmsetup/
	
mkdir ${SP_DIR}/paraprobe_transcoder
cp -rf paraprobe-toolbox/code/paraprobe-transcoder/src/python/* ${SP_DIR}/paraprobe_transcoder


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
cp paraprobe-utils/CMakeFiles/paraprobe-utils.dir/src/cxx/* compiled_code/
cp paraprobe-utils/src/cxx/*.h ${PREFIX}/include/

cd paraprobe-intersector
export CXXFLAGS="$CXXFLAGS -DBOOST_ERROR_CODE_HEADER_ONLY"
cmake -D Boost_NO_BOOST_CMAKE=ON \
	  -D CMAKE_BUILD_TYPE=Release \
	  -D CMAKE_CXX_COMPILER=mpicxx \
	  -D CONDA_PREFIX=${PREFIX} .
make
cp paraprobe_intersector ${PREFIX}/bin/
cd ..

cd paraprobe-nanochem
export CXXFLAGS="$CXXFLAGS -DBOOST_ERROR_CODE_HEADER_ONLY"
cmake -D Boost_NO_BOOST_CMAKE=ON \
	  -D CMAKE_BUILD_TYPE=Release \
	  -D CMAKE_CXX_COMPILER=mpicxx \
	  -D CONDA_PREFIX=${PREFIX} .
make
cp paraprobe_nanochem ${PREFIX}/bin/
cd ..

cd paraprobe-tessellator
export CXXFLAGS="$CXXFLAGS -DBOOST_ERROR_CODE_HEADER_ONLY"
cmake -D Boost_NO_BOOST_CMAKE=ON \
	  -D CMAKE_BUILD_TYPE=Release \
	  -D CMAKE_CXX_COMPILER=mpicxx \
	  -D CONDA_PREFIX=${PREFIX} .
make
cp paraprobe_tessellator ${PREFIX}/bin/
cd ..

cd paraprobe-surfacer
export CXXFLAGS="$CXXFLAGS -DBOOST_ERROR_CODE_HEADER_ONLY"
cmake -D Boost_NO_BOOST_CMAKE=ON \
	  -D CMAKE_BUILD_TYPE=Release \
	  -D CMAKE_CXX_COMPILER=mpicxx \
	  -D CONDA_PREFIX=${PREFIX} .
make
cp paraprobe_surfacer ${PREFIX}/bin/
cd ..

cd paraprobe-spatstat
export CXXFLAGS="$CXXFLAGS -DBOOST_ERROR_CODE_HEADER_ONLY"
cmake -D Boost_NO_BOOST_CMAKE=ON \
	  -D CMAKE_BUILD_TYPE=Release \
	  -D CMAKE_CXX_COMPILER=mpicxx \
	  -D CONDA_PREFIX=${PREFIX} .
make
cp paraprobe_spatstat ${PREFIX}/bin/
cd ..

cd paraprobe-ranger
export CXXFLAGS="$CXXFLAGS -DBOOST_ERROR_CODE_HEADER_ONLY"
cmake -D Boost_NO_BOOST_CMAKE=ON \
	  -D CMAKE_BUILD_TYPE=Release \
	  -D CMAKE_CXX_COMPILER=mpicxx \
	  -D CONDA_PREFIX=${PREFIX} .
make
cp paraprobe_ranger ${PREFIX}/bin/
cd ..

cd paraprobe-distancer
export CXXFLAGS="$CXXFLAGS -DBOOST_ERROR_CODE_HEADER_ONLY"
cmake -D Boost_NO_BOOST_CMAKE=ON \
	  -D CMAKE_BUILD_TYPE=Release \
	  -D CMAKE_CXX_COMPILER=mpicxx \
	  -D CONDA_PREFIX=${PREFIX} .
make
cp paraprobe_distancer ${PREFIX}/bin/
cd ..



