# setting the build flags
if [ "$1" = "" ] ; then
	echo "This script requires information on which mode to install."
	echo "usage: combined_build_install.sh [build opt]"
	echo "  [build opt] can be: gui, cli, or py"
	exit 0 
fi
if [[ $1 == "cli" ]]; then
	enable_cli=1
	enable_gui=0
	enable_py=0
	build_path="build_cli"
elif [[ $1 == "gui" ]]; then
	enable_cli=0
	enable_gui=1
	enable_py=0
	build_path="build_gui"
elif [[ $1 == "py" ]]; then
	enable_cli=0
	enable_gui=0
	enable_py=1
	build_path="build_py"
else
	echo "option $1 is unrecognised"
	exit 0
fi 



if [[ $processor == "gpu" ]]; then
	enable_gpu=1
else
	enable_gpu=0
fi


# build process
mkdir $build_path && cd $build_path 

cmake -D PRISMATIC_ENABLE_GUI=$enable_gui \
	-D PRISMATIC_ENABLE_CLI=$enable_cli \
	-D PRISMATIC_ENABLE_GPU=$enable_gpu \
	-D PRISMATIC_ENABLE_PYPRISMATIC=$enable_py \
	-D CMAKE_INSTALL_PREFIX=$PREFIX \
	-D CMAKE_PREFIX_PATH=${PREFIX} \
	../ 

make  -j${CPU_COUNT}

# install process - this is a little messy for the python interface at the moment
if [[ "$1" == "py" ]]; then
	install_dir=${PREFIX}/lib/python${PY_VER}/site-packages/pyprismatic
	mkdir $install_dir
	cp core.* $install_dir
	cp ../pyprismatic/* $install_dir
else
	make install
fi

