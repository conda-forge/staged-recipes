ECHO Building cudatoolkit ...

SET filename=cuda_%PKG_VERSION%.exe
SET install_dir=%CONDA_PREFIX%\tmp\cuda

mkdir %install_dir%
mkdir %PREFIX%\lib %PREFIX%\include

./%filename% --silent --toolkit --toolkitpath=%install_dir% --override

DIR %install_dir%

ECHO Removing unnecessary folders ...
SET excluded_dirs=bin doc extras jre libnsight libnvvp nsightee_plugins nvml pkgconfig samples tools
for %%f in (%excluded_dirs%) DO (
    RD /S /Q %install_dir%\%%f
)

SET cuda_libs=cudart*.dll cudart_static*.lib cudadevrt*.lib
SET "cuda_libs=%cuda_libs% cufft*.dll cufftw*.dll cufft*.lib cufftw*.lib"
SET "cuda_libs=%cuda_libs% cublas*.dll cublas_device*.lib"
SET "cuda_libs=%cuda_libs% nvblas*.dll"
SET "cuda_libs=%cuda_libs% cusparse*.dll cusparse*.lib"
SET "cuda_libs=%cuda_libs% cusolver*.dll cusolver*.lib"
SET "cuda_libs=%cuda_libs% curand*.dll curand*.lib"
SET "cuda_libs=%cuda_libs% nvgraph*.dll nvgraph*.lib"
SET "cuda_libs=%cuda_libs% nppc*.dll nppc*.lib nppial*.dll nppial*.lib"
SET "cuda_libs=%cuda_libs% nppicc*.dll nppicc*.lib nppicom*.dll"
SET "cuda_libs=%cuda_libs% nppicom*.lib nppidei*.dll nppidei*.lib"
SET "cuda_libs=%cuda_libs% nppif*.dll nppif*.lib nppig*.dll nppig*.lib"
SET "cuda_libs=%cuda_libs% nppim*.dll nppim*.lib nppist*.dll nppist*.lib"
SET "cuda_libs=%cuda_libs% nppisu*.dll nppisu*.lib nppitc*.dll"
SET "cuda_libs=%cuda_libs% nppitc*.lib npps*.dll npps*.lib"
SET "cuda_libs=%cuda_libs% nvrtc*.dll nvrtc-builtins*.dll"
SET "cuda_libs=%cuda_libs% nvvm*.dll"
SET "cuda_libs=%cuda_libs% libdevice.10.bc"
SET "cuda_libs=%cuda_libs% cupti*.dll"
SET "cuda_libs=%cuda_libs% nvToolsExt*.dll nvToolsExt*.lib"

SET cuda_h=cuda_occupancy.h

ECHO Copying lib files:
FOR %%f in %cuda_libs% DO (
    ECHO - %%f ...
    FOR /R %install_dir% %x IN (%%f) DO COPY "%x" %PREFIX%\lib\ /Y;
)

ECHO Copying header files:
for %%f in %cuda_h% DO (
    ECHO - %%f ...
    FOR /R %install_dir% %x IN (%%f) DO COPY "%x" %PREFIX%\include\ /Y;
)

ECHO Removing installation folder ...
RD /S /Q %install_dir%
