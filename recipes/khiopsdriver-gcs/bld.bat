REM Echo all output
@echo on

REM We need to use the subst command to shorten the paths:  
REM "aws-sdk-cpp's buildsystem uses very long paths and may fail on your system. 
REM We recommend moving vcpkg to a short path such as 'C:\src\vcpkg' or using the subst command."
subst W: %CD% 
W:

REM Configure project
cmake --fresh -G Ninja -D CMAKE_BUILD_TYPE=Release -D VCPKG_BUILD_TYPE=release -D CMAKE_TOOLCHAIN_FILE=vcpkg/scripts/buildsystems/vcpkg.cmake -B builds/conda -S .

REM Build
cmake --build builds/conda --parallel --target khiopsdriver_file_gcs

REM Copy the lib for the driver package
copy builds\conda\bin\khiopsdriver_file_gcs.dll %LIBRARY_BIN%\libkhiopsdriver_file_gcs.dll
