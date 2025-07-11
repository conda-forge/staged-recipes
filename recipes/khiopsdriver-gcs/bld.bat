REM Echo all output
@echo on

REM Configure project
cmake --fresh -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      -G Ninja -B builds\conda -S .
if errorlevel 1 exit 1

REM Build
cmake --build builds\conda --parallel --target khiopsdriver_file_gcs
if errorlevel 1 exit 1

REM Copy the lib for the driver package
copy builds\conda\bin\khiopsdriver_file_gcs.dll %LIBRARY_PREFIX%\bin\libkhiopsdriver_file_gcs.dll
cmake --install builds\conda
dir %LIBRARY_PREFIX%
dir %LIBRARY_PREFIX%\bin