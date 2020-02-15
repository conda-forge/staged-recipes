cd $SRC_DIR

export OS=linux
export ENV=gnu
if [ "$(uname)" == "Darwin" ]; then
	export OS=macosx
fi
if [ "$ARCH" == "32" ]; then
	export ENV=gnu32
fi

export EXT=${OS}_${ENV}

make OS=$OS ENV=$ENV CC_${EXT}=$CC LD_${EXT}=$CC FC_${EXT}=$FC CURSES=no all
make INSTALLDIR=$PREFIX install
