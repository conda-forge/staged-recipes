mkdir build
cd build

cmake ../^
    -G"Visual Studio 14 2015 Win64"^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%"^
	-DBUILD_EXAMPLE=OFF^
	-DBINDER_MATLAB=OFF^
    -DBINDER_PYTHON3=ON^
    -DPython3_EXECUTABLE="%PREFIX%/python.exe"

cmake --build ./^
    --config Release^
    --target install
