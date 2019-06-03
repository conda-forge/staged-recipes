mkdir build
cd build

cmake ../^
    -G"%Visual Studio 15 2017 Win64%"^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%"^
    -DDLIB_PNG_SUPPORT=OFF^
    -DDLIB_JPEG_SUPPORT=OFF^
    -DBUILD_SHARED_LIBS=OFF^
    -DDLIB_GIF_SUPPORT=OFF^
    -DDLIB_ISO_CPP_ONLY=OFF^
    -DDLIB_JPEG_SUPPORT=OFF^
    -DDLIB_LINK_WITH_SQLITE3=OFF^
    -DDLIB_NO_GUI_SUPPORT=ON^
    -DDLIB_PNG_SUPPORT=OFF^
    -DDLIB_USE_BLAS=OFF^
    -DDLIB_USE_CUDA=OFF^
    -DDLIB_USE_MKL_FFT=OFF^
    -DDLIB_USE_LAPACK=ON
    
cmake --build ./^
    --config Release^
    --target install
