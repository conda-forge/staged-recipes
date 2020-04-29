
export XERCESCROOT=${PREFIX}
export XALANCROOT=$(pwd)


if [ $(uname) == Darwin ]; then
    platform=macosx
else
    platform=linux
    export CXXCPP=${CPP}
fi

./runConfigure -p ${platform} -c $CC -x $CXX -b 64 -P ${PREFIX} ${EXTRA_CXX_OPTIONS}

make
make install
