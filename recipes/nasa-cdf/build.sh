cd $SRC_DIR

export OS=linux
export ENV=gnu
if [ "$ARCH" == "32" ]; then
	export ENV=gnu32
fi
if [ "$(uname)" == "Darwin" ]; then
	export OS=macosx
	if [ "$ARCH" == "32" ]; then
		export ENV=i386
	else
		export ENV=x86_64
	fi
fi

export EXT=${OS}_${ENV}

make OS=$OS ENV=$ENV CC_${EXT}=$CC LD_${EXT}=$CC FC_${EXT}=$FC CURSES=no all
make INSTALLDIR=$PREFIX install
