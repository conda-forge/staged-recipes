SETLOCAL ENABLEDELAYEDEXPANSION

ECHO Building cudatoolkit ...

SET filename=cuda_%PKG_VERSION%.exe
SET install_dir="%ProgramFiles%\NVIDIA GPU Computing Toolkit\CUDA\v%PKG_VERSION%"

:: CREATE A DIRECTORY WHERE FILES WOULD BE EXTRACTED
MKDIR "%PREFIX%\DLLs" "%PREFIX%\Library\bin" "%PREFIX%\include"

ECHO Install cudatoolkit
%filename% -s nvcc_%PKG_VERSION% cuobjdump_%PKG_VERSION% nvprune_%PKG_VERSION% ^
cupti_%PKG_VERSION% gpu_library_advisor_%PKG_VERSION% memcheck_%PKG_VERSION% nvdisasm_%PKG_VERSION% ^
nvprof_%PKG_VERSION% visual_profiler_%PKG_VERSION% visual_studio_integration_%PKG_VERSION% ^
demo_suite_%PKG_VERSION% documentation_%PKG_VERSION% cublas_%PKG_VERSION% ^
cublas_dev_%PKG_VERSION% cudart_%PKG_VERSION% cufft_%PKG_VERSION% cufft_dev_%PKG_VERSION% ^
curand_%PKG_VERSION% curand_dev_%PKG_VERSION% cusolver_%PKG_VERSION% cusolver_dev_%PKG_VERSION% ^
cusparse_%PKG_VERSION% cusparse_dev_%PKG_VERSION% nvgraph_%PKG_VERSION% ^
nvgraph_dev_%PKG_VERSION% npp_%PKG_VERSION%	NPP npp_dev_%PKG_VERSION% nvrtc_%PKG_VERSION% ^
nvrtc_dev_%PKG_VERSION% nvml_dev_%PKG_VERSION% occupancy_calculator_%PKG_VERSION% ^
fortran_examples_%PKG_VERSION%

DIR /S "%ProgramFiles%\NVIDIA Corporation"

ECHO Removing some unnecessary folders ...
SET excluded_dirs=CUDADocument CUDASamples Doc fortran_examples

FOR %%f IN (%excluded_dirs%) DO (
    RD /S /Q "%install_dir%\%%f"
)

SET cuda_libs=cudart.dll cudart_static.lib cudadevrt.lib ^
cufft.dll cufftw.dll cufft.lib cufftw.lib ^
cublas.dll cublas_device.lib ^
nvblas.dll ^
cusparse.dll cusparse.lib ^
cusolver.dll cusolver.lib ^
curand.dll curand.lib ^
nvgraph.dll nvgraph.lib ^
nppc.dll nppc.lib nppial.dll nppial.lib ^
nppicc.dll nppicc.lib nppicom.dll ^
nppicom.lib nppidei.dll nppidei.lib ^
nppif.dll nppif.lib nppig.dll nppig.lib ^
nppim.dll nppim.lib nppist.dll nppist.lib ^
nppisu.dll nppisu.lib nppitc.dll ^
nppitc.lib npps.dll npps.lib ^
nvrtc.dll nvrtc-builtins.dll ^
nvvm.dll ^
libdevice.10.bc ^
cupti.dll

SET cuda_nvtoolsext_dir="%ProgramFiles%\NVIDIA Corporation"
SET cuda_nvtoolsext_files=nvToolsExt.dll nvToolsExt.lib
SET cuda_dlls=nvvm.dll libdevice.10.bc
SET cuda_h=cuda_occupancy.h

ECHO Copying lib files:
FOR %%f in (%cuda_libs%) DO (
    SET fname=%%f
	SET fname_wild_card=!fname:~0,-4!*!fname:~-4!
	ECHO !fname_wild_card!
	FOR /R %install_dir% %%x IN (!fname_wild_card!) DO COPY "%%x" %PREFIX%\Library\bin /Y;
)

ECHO Copying nvToolsExt files:
FOR %%f in (%cuda_nvtoolsext_files%) DO (
    SET fname=%%f
	SET fname_wild_card=!fname:~0,-4!*!fname:~-4!
	ECHO !fname_wild_card!
	FOR /R %cuda_nvtoolsext_dir% %%x IN (!fname_wild_card!) DO COPY "%%x" %PREFIX%\Library\bin /Y;
)

ECHO Copying dll files:
FOR %%f in (%cuda_dlls%) DO (
    SET fname=%%f
	SET fname_wild_card=!fname:~0,-4!*!fname:~-4!
	ECHO !fname_wild_card!
    FOR /R %install_dir%" %%x IN (!fname_wild_card!) DO COPY "%%x" %PREFIX%\DLLs /Y;
)

ECHO Copying header files:
for %%f in (%cuda_h%) DO (
    SET fname=%%f
	SET fname_wild_card=!fname:~0,-4!*!fname:~-4!
	ECHO !fname_wild_card!
    FOR /R %install_dir% %%x IN (!fname_wild_card!) DO COPY "%%x" %PREFIX%\Library\include\ /Y;
)
