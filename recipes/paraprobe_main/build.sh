
mpifort=$(which mpifort)
mv $mpifort $mpifort.orig
sed 's/\(enable_wrapper_rpath=\)"yes"/\1"no"/' $mpifort.orig >$mpifort
chmod +x $mpifort

echo ${SP_DIR}

export EXTERNAL_CGAL_INCLUDE_DIR="${BUILD_PREFIX}/include/"
echo ${EXTERNAL_CGAL_INCLUDE_DIR}

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

cp ../thirdparty/mandatory/hdf5cxxwrapper/src/cxx/* src/cxx/
cp ../../../voro++/src/* src/cxx/
#add cgal


cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=mpicxx -DCONDA_PREFIX=${PREFIX} .
make
ls
cd ..

mkdir compiled_code
#cp paraprobe-utils/CMakeFiles/paraprobe-utils.dir${SRC_DIR}/paraprobe-toolbox/code/paraprobe-utils/src/cxx/* compiled_code/
cp paraprobe-utils/CMakeFiles/paraprobe-utils.dir/src/cxx/* compiled_code/

cd paraprobe-surfacer
cmake -DBoost_NO_BOOST_CMAKE=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=mpicxx -DCONDA_PREFIX=${PREFIX} .
make
cp paraprobe_surfacer ${PREFIX}/bin/
cd ..

cd paraprobe-ranger
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=mpicxx -DCONDA_PREFIX=${PREFIX} .
make
cp paraprobe_ranger ${PREFIX}/bin/
cd ..

cd paraprobe-distancer
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=mpicxx -DCONDA_PREFIX=${PREFIX} .
make
cp paraprobe_distancer ${PREFIX}/bin/
cd ..

cd paraprobe-tessellator
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=mpicxx -DCONDA_PREFIX=${PREFIX} .
make
cp paraprobe_tessellator ${PREFIX}/bin/
cd ..

cd paraprobe-spatstat
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=mpicxx -DCONDA_PREFIX=${PREFIX} .
make
cp paraprobe_spatstat ${PREFIX}/bin/
cd ..

cd paraprobe-nanochem
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=mpicxx -DCONDA_PREFIX=${PREFIX} .
make
cp paraprobe_nanochem ${PREFIX}/bin/
cd ..

cd paraprobe-intersector
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=mpicxx -DCONDA_PREFIX=${PREFIX} .
make
cp paraprobe_intersector ${PREFIX}/bin/
cd ..



