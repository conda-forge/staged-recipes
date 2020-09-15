mkdir build
cd build

cmake .. ^
    %CMAKE_ARGS%  ^
	-G "NMake Makefiles"

nmake install