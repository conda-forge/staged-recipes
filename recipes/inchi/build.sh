set -e -x

# cp LICENSE $PREFIX/LICENSE
nprocs=`getconf _NPROCESSORS_ONLN`
scons install -j $nprocs PREFIX=$PREFIX
