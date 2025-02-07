REM Echo all output
@echo on

REM Build the Khiops binaries
REM Specify empty target platform and generator toolset for CMake with Ninja on
REM Windows
REM Ninja does not expect target platform and generator toolset.
REM However, CMake Windows presets set these, which results in Ninja failure.
cmake -B conda-build -S . -D BUILD_JARS=OFF -D TESTING=OFF -D CMAKE_BUILD_TYPE=Release -G Ninja  -A "" -T ""
cmake --build conda-build --parallel --target MODL MODL_Coclustering KhiopsNativeInterface _khiopsgetprocnumber


mkdir %PREFIX%\bin

REM Copy the khiops-core binaries to the Conda PREFIX path: MODL, MODL_Coclustering and _khiopsgetprocnumber.
REM This last one is used by khiops_env to get the physical cores number 
copy conda-build\bin\MODL.exe %PREFIX%\bin
copy conda-build\bin\MODL_Coclustering.exe %PREFIX%\bin
copy conda-build\bin\_khiopsgetprocnumber.exe %PREFIX%\bin

REM Copy the KhiopsNativeInterface libs for the kni package
copy conda-build\bin\KhiopsNativeInterface.dll %PREFIX%\bin
copy conda-build\lib\KhiopsNativeInterface.lib %PREFIX%\lib

REM Copy the scripts to the Conda PREFIX path
copy conda-build\tmp\khiops_env.cmd %PREFIX%\bin
copy packaging\windows\khiops_coclustering.cmd %PREFIX%\bin
copy packaging\windows\khiops.cmd %PREFIX%\bin

if errorlevel 1 exit 1
