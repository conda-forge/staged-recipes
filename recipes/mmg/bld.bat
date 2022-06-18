@call "%VS140COMNTOOLS%VsDevCmd.bat"
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX}  -DUSE_VTK=OFF
devenv mmg.sln /build
