mkdir build
cd build


cmake ^
    -G "%CMAKE_GENERATOR%" ^
    -DCMAKE_PREFIX_PATH=$PREFIX ^
	-DCMAKE_3RDPARTY_DIR="%LIBRARY_LIB%" ^
	-DUSE_TCL=NO ^
	-DBUILD_MODULE_DRAW=NO ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ..

msbuild /m