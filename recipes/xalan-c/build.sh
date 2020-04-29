
export XERCESCROOT=${PREFIX}
export XALANCROOT=$(pwd)


if [ $(uname) == Darwin ]; then
    platform=macosx
else
    platform=linux
    export CXXCPP=${CPP}
fi

./runConfigure -p ${platform} -c $CC -x $CXX -b 64 -P ${PREFIX}

make
make install
