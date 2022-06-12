#!/bin/bash
set -e

echo "**************** A S T E R  B U I L D  S T A R T S  H E R E ****************"

# https://docs.conda.io/projects/conda-build/en/latest/resources/compiler-tools.html#an-aside-on-cmake-and-sysroots
CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")

#cp $PREFIX/lib/libboost_python${CONDA_PY}.so.* $PREFIX/lib/libboost_python3.so
#ls -l $PREFIX/lib/libboost*.so

#export FC=/usr/bin/gfortran
#export CC=/usr/bin/gcc
#export CXX=/usr/bin/g++

#export CFLAGS="${CFLAGS} -i sysroot ${CONDA_BUILD_SYSROOT}"
#echo "CFLAGS=\"${CFLAGS} -i sysroot ${CONDA_BUILD_SYSROOT}\"" >> setup.cfg
sed -i 's@cmake\ ..\ @cmake\ ..\ -DCMAKE_TOOLCHAIN_FILE='"${RECIPE_DIR}"'/cross-linux.cmake\ @g' products.py

sed -i 's/pylib = SC.get_python_lib(standard_lib=True)/pylib = osp.join(cfg["HOME_PYTHON"],"lib")/g' setup.py

echo "PREFIX : ${PREFIX}"
echo "CONDA_BUILD_SYSROOT : ${CONDA_BUILD_SYSROOT}"
# echo "CC_FOR_BUILD : ${CC_FOR_BUILD}"
echo "CC : ${CC}"
echo "CC=\"${CC}\"" >> setup.cfg
echo "CFLAGS : ${CFLAGS}"
echo "CFLAGS=\"${CFLAGS} -isysroot ${CONDA_BUILD_SYSROOT} \"" >> setup.cfg
echo "CXX : ${CXX}"
echo "CXX=\"${CXX}\"" >> setup.cfg
echo "CXXFLAGS : ${CXXFLAGS}"
echo "CXXFLAGS=\"${CXXFLAGS} -isysroot ${CONDA_BUILD_SYSROOT} \"" >> setup.cfg
echo "F90 : ${F90}"
echo "F90=\"${F90}\"" >> setup.cfg
echo "FFLAGS : ${FFLAGS}"
echo "F90FLAGS=\"${FFLAGS} -isysroot ${CONDA_BUILD_SYSROOT} \"" >> setup.cfg
echo "LD : ${LD}"
echo "LD=\"${LD}\"" >> setup.cfg
#echo "LDFLAGS : ${LDFLAGS}"
#echo "LDFLAGS=\"${LDFLAGS}\"" >> setup.cfg
#echo "LDFLAGS=\"--sysroot ${CONDA_BUILD_SYSROOT} -L${CONDA_BUILD_SYSROOT}/lib64 -lm -lpthread -L${PREFIX}/lib -lz\"" >> setup.cfg
echo "LDFLAGS=\"--sysroot ${CONDA_BUILD_SYSROOT} -L${CONDA_BUILD_SYSROOT}/lib64 -lm -lpthread -L${CONDA_BUILD_SYSROOT}/usr/lib64 -lrt -ldl -L${PREFIX}/lib -lz -lgomp\"" >> setup.cfg

echo "CXXLIB=\"-L${PREFIX}/lib -lstdc++\"" >> setup.cfg
echo "MATHLIB=\"-L${PREFIX}/lib -llapack -lblas\"" >> setup.cfg
#echo "OTHERLIB=\"-L${CONDA_BUILD_SYSROOT}/lib64 -lm -lpthread -L${PREFIX}/lib -lz\"" >> setup.cfg
#echo "PYTHON_LIBRARY=\"${PREFIX}/lib/libpython3.8.so\"" >> setup.cfg
echo "HOME_PYTHON=\"${PREFIX}\"" >> setup.cfg


echo "HOME_BOOST=\"$PREFIX/lib/\"" >> setup.cfg
echo "LIBNAME_BOOST=\"boost_python${CONDA_PY}\"" >> setup.cfg
echo "_install_hdf5 = False" >> setup.cfg
echo "HOME_HDF=\"$PREFIX\"" >> setup.cfg
echo "_install_med = False" >> setup.cfg
echo "HOME_MED=\"$PREFIX\"" >> setup.cfg
#echo "_install_metis = False" >> setup.cfg
#echo "HOME_METIS=\"$PREFIX\"" >> setup.cfg
#echo "_install_mfront = False" >> setup.cfg
echo "_install_tfel = False" >> setup.cfg
echo "HOME_MFRONT=\"$PREFIX\"" >> setup.cfg
#echo "_install_mumps = False" >> setup.cfg
#echo "HOME_MUMPS=\"$PREFIX\"" >> setup.cfg
echo "_install_scotch = False" >> setup.cfg
echo "HOME_SCOTCH=\"$PREFIX\"" >> setup.cfg
$PYTHON setup.py install --prefix=$PREFIX --noprompt hdf5 med scotch astk metis tfel mumps homard aster
#$PYTHON setup.py install --prefix=$PREFIX --noprompt hdf5 med scotch astk metis mumps

#ln -s $PREFIX/15.2/lib/aster $SP_DIR
#ln -s $PREFIX/15.2/lib/aster $STDLIB_DIR

#echo "vers : stable:$PREFIX/15.2/share/aster" >> $PREFIX/etc/codeaster/aster
sed -i 's/\/usr\/bin\/bash/\/usr\/bin\/env bash/g' $PREFIX/bin/as_run

find $PREFIX -name "profile.sh" -exec sed -i 's/PYTHONHOME=/#PYTHONHOME=/g' {} \;
find $PREFIX -name "profile.sh" -exec sed -i 's/export PYTHONHOME/#export PYTHONHOME/g' {} \;

echo "**************** A S T E R  B U I L D  E N D S  H E R E ****************"