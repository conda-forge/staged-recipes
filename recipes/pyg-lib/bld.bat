@REM NOTE(hadim): the below is WIP and does not work.
@REM We must wait for upstream to provide Windows compatibility.

@echo On

if "%cuda_compiler_version%" == "None" (
    set FORCE_CUDA=0
) else (
    set FORCE_CUDA=1
)

if "%build_with_cuda%" == "" goto cuda_flags_end

set CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v%desired_cuda%
set CUDA_BIN_PATH=%CUDA_PATH%\bin

:cuda_flags_end

set DISTUTILS_USE_SDK=1

set CMAKE_INCLUDE_PATH=%LIBRARY_PREFIX%\include
set LIB=%LIBRARY_PREFIX%\lib;%LIB%

IF "%build_with_cuda%" == "" goto cuda_end

set "PATH=%CUDA_BIN_PATH%;%PATH%"
set CUDNN_INCLUDE_DIR=%LIBRARY_PREFIX%\include

:cuda_end

set Torch_DIR=%SP_DIR%\torch"
@REM set USE_MKL_BLAS=1

set FORCE_NINJA=1
set EXTERNAL_PHMAP_INCLUDE_DIR="%BUILD_PREFIX%\include"
set EXTERNAL_CUTLASS_INCLUDE_DIR="%BUILD_PREFIX%\include"

pip install . -vvv
