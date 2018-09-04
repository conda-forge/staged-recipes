
#if [ "$(uname)" == "Linux" ]
#then
    #export CXXFLAGS="${CXXFLAGS} -L${PREFIX}/lib -Wl,-rpath-link,${PREFIX}/lib"
#fi

cd third_party/ASL
./getASL.sh
cd solvers
./configurehere
make
cd ../../../

mkdir build
cd build

cmake ..

make VERBOSE=1 -j${CPU_COUNT}
make 
