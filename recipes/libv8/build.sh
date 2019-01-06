cd build
git clone https://chromium.googlesource.com/external/gyp
cd ..
sed -i.bak "s/-Werror//g" build/standalone.gypi
sed -i.bak "s/-Werror//g" build/common.gypi
build/gyp_v8
export CPP_INCLUDE_PATH=../src/third_party
export CPLUS_INCLUDE_PATH=../src/third_party
export CXX_INCLUDE_PATH=../src/third_party
make x64.release BUILDTYPE=Release snapshot=off library=shared
make libv8.so
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include
mv out/x64.release/d8 ${PREFIX}/bin/
mv out/x64.release/lib.target/libv8.so ${PREFIX}/lib/
cp include/*.h ${PREFIX}/include/
