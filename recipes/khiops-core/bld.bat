REM Echo all output
@echo on

REM Build the Khiops binaries
cmake -B build\conda -S . -D BUILD_JARS=OFF -D TESTING=OFF -D CMAKE_BUILD_TYPE=Release -G Ninja
cmake --build build\conda --parallel --target MODL MODL_Coclustering KhiopsNativeInterface _khiopsgetprocnumber

mkdir %PREFIX%\bin

REM Copy the khiops-core binaries to the Conda PREFIX path: MODL, MODL_Cocluetsring and _khiopsgetprocnumber.
REM This last one is used by khiops_env to get the physical cores number 
copy build\conda\bin\MODL.exe %LIBRARY_BIN%
copy build\conda\bin\MODL_Coclustering.exe %LIBRARY_BIN%
copy build\conda\bin\_khiopsgetprocnumber.exe %LIBRARY_BIN%

REM Copy the KhiopsNativeInterface libs for the kni package
copy build\conda\bin\KhiopsNativeInterface.dll %LIBRARY_BIN%
copy build\conda\lib\KhiopsNativeInterface.lib %LIBRARY_LIB%

REM Copy the scripts to the Conda PREFIX path
copy build\conda\tmp\khiops_env.cmd %LIBRARY_BIN%
copy packaging\windows\khiops_coclustering.cmd %LIBRARY_BIN%
copy packaging\windows\khiops.cmd %LIBRARY_BIN%

REM Copy the header file
copy src\Learning\KhiopsNativeInterface\KhiopsNativeInterface.h %LIBRARY_INC%


if errorlevel 1 exit 1
