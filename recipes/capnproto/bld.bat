mkdir build
cd build
:: CAPNP_LITE=ON is required since Cap'n Proto doesn't have complete support on MSVC:
:: https://github.com/sandstorm-io/capnproto/issues/227
cmake -DCAPNP_LITE=ON -DBUILD_TESTING=OFF -DCMAKE_INSTALL_PREFIX=%PREFIX% ..\c++

nmake
nmake install
