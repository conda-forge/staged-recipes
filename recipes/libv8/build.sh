cd build
git clone --depth 1 https://chromium.googlesource.com/external/gyp
cd ..
python2 build/gyp_v8
make x64.release BUILDTYPE=Release snapshot=off library=shared werror=no CXX=$CXX LD=$CXX
make libv8.so
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include
mv out/x64.release/d8 ${PREFIX}/bin/
mv out/x64.release/lib.target/libv8.so ${PREFIX}/lib/
cp include/*.h ${PREFIX}/include/
