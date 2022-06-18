mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -G"NMake Makefiles JOM" -DCMAKE_INSTALL_PREFIX=${PREFIX}  -DUSE_VTK=OFF
devenv mmg.sln /build
