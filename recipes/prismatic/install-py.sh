if [[ $processor == "gpu" ]]; then
	enable_gpu=1
else
	enable_gpu=0
fi


mkdir build_py && cd build_py 

cmake -D PRISMATIC_ENABLE_GUI=0 \
	-D PRISMATIC_ENABLE_CLI=0 \
	-D PRISMATIC_ENABLE_GPU=$enable_gpu \
	-D PRISMATIC_ENABLE_PYPRISMATIC=1 \
	-D CMAKE_INSTALL_PREFIX=$PREFIX \
	-D CMAKE_PREFIX_PATH=${PREFIX} \
	../ 

make  -j${CPU_COUNT}


# install the python interface (this isn't setup in the CMake file)
install_dir=${PREFIX}/lib/python3.7/site-packages/pyprismatic
mkdir $install_dir
cp core.* $install_dir
cp ../pyprismatic/* $install_dir



