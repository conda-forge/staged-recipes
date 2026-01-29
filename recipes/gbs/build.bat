
mkdir build-conda
cd build-conda

cmake .. ^
-D CMAKE_BUILD_TYPE:STRING="Release" ^
-D USE_OCCT_UTILS=OFF ^
-D USE_CUDA=OFF ^
-D GBS_BUILD_TESTS=OFF ^
-D USE_RENDER=ON ^
-D USE_PYTHON_BINDINGS=ON ^
-D BUILD_DOC=OFF ^
-D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
-G "Ninja" ^
--log-level=DEBUG ^
-Wno-dev

ninja install

cd ..
