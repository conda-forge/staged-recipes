@echo off

set CUDA_PATH_V9_0=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v9.0
set CUDA_PATH=%CUDA_PATH_V9_0%

set CUDA_BIN_PATH=%CUDA_PATH%\bin
set TORCH_CUDA_ARCH_LIST=3.5;5.0+PTX;6.0;6.1;7.0
set TORCH_NVCC_FLAGS=-Xfatbin -compress-all
set PYTORCH_BINARY_BUILD=1
set TH_BINARY_BUILD=1
set PYTORCH_BUILD_VERSION=%PKG_VERSION%
set PYTORCH_BUILD_NUMBER=%PKG_BUILDNUM%

set DISTUTILS_USE_SDK=1

curl https://s3.amazonaws.com/ossci-windows/mkl_2018.2.185.7z -k -O
7z x -aoa mkl_2018.2.185.7z -omkl
set CMAKE_INCLUDE_PATH=%SRC_DIR%\\mkl\\include
set LIB=%SRC_DIR%\\mkl\\lib;%LIB%

curl https://s3.amazonaws.com/ossci-windows/magma_cuda90_release_mkl_2018.2.185.7z -k -O
7z x -aoa magma_cuda90_release_mkl_2018.2.185.7z -omagma_cuda90_release
set MAGMA_HOME=%cd%\magma_cuda90_release

mkdir %SRC_DIR%\\tmp_bin
curl -k https://s3.amazonaws.com/ossci-windows/sccache.exe --output %SRC_DIR%\\tmp_bin\\sccache.exe
copy %SRC_DIR%\\tmp_bin\\sccache.exe %SRC_DIR%\\tmp_bin\\nvcc.exe

set CUDA_NVCC_EXECUTABLE=%SRC_DIR%\\tmp_bin\\nvcc
set "PATH=%SRC_DIR%\\tmp_bin;%CUDA_BIN_PATH%;C:\Program Files\CMake\bin;%PATH%"

set CMAKE_GENERATOR=Ninja

sccache --stop-server
sccache --start-server
sccache --zero-stats

set CC=sccache cl
set CXX=sccache cl

pip install ninja
python setup.py install

pip uninstall -y ninja

taskkill /im sccache.exe /f /t || ver > nul

copy "%CUDA_BIN_PATH%\cusparse64_%CUDA_VERSION%.dll*" %SP_DIR%\torch\lib
copy "%CUDA_BIN_PATH%\cublas64_%CUDA_VERSION%.dll*" %SP_DIR%\torch\lib
copy "%CUDA_BIN_PATH%\cudart64_%CUDA_VERSION%.dll*" %SP_DIR%\torch\lib
copy "%CUDA_BIN_PATH%\curand64_%CUDA_VERSION%.dll*" %SP_DIR%\torch\lib
copy "%CUDA_BIN_PATH%\cufft64_%CUDA_VERSION%.dll*" %SP_DIR%\torch\lib
copy "%CUDA_BIN_PATH%\cufftw64_%CUDA_VERSION%.dll*" %SP_DIR%\torch\lib

copy "%CUDA_BIN_PATH%\cudnn64_%CUDNN_VERSION%.dll*" %SP_DIR%\torch\lib
copy "%CUDA_BIN_PATH%\nvrtc64_%CUDA_VERSION%.dll*" %SP_DIR%\torch\lib
copy "%CUDA_BIN_PATH%\nvrtc-builtins64_%CUDA_VERSION%.dll*" %SP_DIR%\torch\lib

copy "C:\Program Files\NVIDIA Corporation\NvToolsExt\bin\x64\nvToolsExt64_1.dll*" %SP_DIR%\torch\lib
copy "C:\Windows\System32\nvcuda.dll" %SP_DIR%\torch\lib
copy "C:\Windows\System32\nvfatbinaryloader.dll" %SP_DIR%\torch\lib
