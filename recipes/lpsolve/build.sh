if [ `uname` == "Darwin" ]; then
    CCC="ccc.osx"
    PLATFORM="osx64"
    SHARED_LIB_NAME="liblpsolve55.dylib"
else
    CCC="ccc"
    PLATFORM="ux64"
    SHARED_LIB_NAME="liblpsolve55.so"
fi

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include

# build library
cd lpsolve55
sh ${CCC}
cp bin/${PLATFORM}/${SHARED_LIB_NAME} ${PREFIX}/lib/
cd ..

# build executable
cd lp_solve
sh ${CCC}
cp bin/${PLATFORM}/lp_solve ${PREFIX}/bin/
cd ..

# install headers
cp *.h ${PREFIX}/include/

if [ `uname` == "Darwin" ]; then
    # fix rpath on macOS
    install_name_tool -id @rpath/${SHARED_LIB_NAME} ${PREFIX}/lib/${SHARED_LIB_NAME}
fi
