ECHO Building cudatoolkit ...

SET filename=cuda_%PKG_VERSION%.exe
SET install_dir=%CUDA_PREFIX%\tmp\cuda

:: REMOVE THE DIR IF EXISTS
RMDIR /S /Q %install_dir%

:: CREATE A DIRECTORY WHERE FILES WOULD BE EXTRACTED
MKDIR %install_dir%
MKDIR %PREFIX%\lib %PREFIX%\include

ECHO Extracting files
7za x -o%install_dir% %filename%

DIR %install_dir%

ECHO Removing some unnecessary folders ...
SET excluded_dirs=CUDADocument CUDASamples Doc fortran_examples

FOR %%f IN (%excluded_dirs%) DO (
    RD /S /Q %install_dir%\%%f
)

SET cuda_libs=cudart*.dll cudart_static*.lib cudadevrt*.lib ^
cufft*.dll cufftw*.dll cufft*.lib cufftw*.lib ^
cublas*.dll cublas_device*.lib ^
nvblas*.dll ^
cusparse*.dll cusparse*.lib ^
cusolver*.dll cusolver*.lib ^
curand*.dll curand*.lib ^
nvgraph*.dll nvgraph*.lib ^
nppc*.dll nppc*.lib nppial*.dll nppial*.lib ^
nppicc*.dll nppicc*.lib nppicom*.dll ^
nppicom*.lib nppidei*.dll nppidei*.lib ^
nppif*.dll nppif*.lib nppig*.dll nppig*.lib ^
nppim*.dll nppim*.lib nppist*.dll nppist*.lib ^
nppisu*.dll nppisu*.lib nppitc*.dll ^
nppitc*.lib npps*.dll npps*.lib ^
nvrtc*.dll nvrtc-builtins*.dll ^
nvvm*.dll ^
libdevice.10.bc ^
cupti*.dll ^
nvToolsExt*.dll nvToolsExt*.lib

SET cuda_h=cuda_occupancy.h

ECHO Copying lib files:
FOR %%f in (%cuda_libs%) DO (
    ECHO - %%f ...
    FOR /R %install_dir% %%x IN (%%f) DO COPY "%%x" %PREFIX%\Library\bin /Y;
)

ECHO Copying header files:
for %%f in (%cuda_h%) DO (
    ECHO - %%f ...
    FOR /R %install_dir% %%x IN (%%f) DO COPY "%%x" %PREFIX%\Library\include\ /Y;
)

ECHO Removing installation folder ...
RD /S /Q %install_dir%
