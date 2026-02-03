REM Echo all output
@echo on

REM Configure project
cmake --fresh -G Ninja -D CMAKE_BUILD_TYPE=Release -B builds\conda -S . %CMAKE_ARGS%

REM Build
cmake --build builds\conda --parallel --target khiopsdriver_file_azure

REM Copy the lib for the driver package
cmake --install builds\conda --prefix %PREFIX%\Library
