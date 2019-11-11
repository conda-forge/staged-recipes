if [[ $processor == "gpu" ]]; then
	enable_gpu=1
else
	enable_gpu=0
fi

mkdir build_cli && cd build_cli 

cmake -D PRISMATIC_ENABLE_GUI=0 \
	-D PRISMATIC_ENABLE_CLI=1 \
	-D PRISMATIC_ENABLE_GPU=$enable_gpu \
	-D PRISMATIC_ENABLE_PYPRISMATIC=0 \
	-D CMAKE_INSTALL_PREFIX=$PREFIX \
	-D CMAKE_PREFIX_PATH=${PREFIX} \
	../ 

make  -j${CPU_COUNT}

make install

