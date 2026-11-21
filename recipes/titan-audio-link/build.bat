@echo off
cmake -S "%SRC_DIR%\Titan-Audio-Link-C-ffi" -B "%SRC_DIR%\sdk_build" -G Ninja -DCMAKE_BUILD_TYPE=Release -DPRODUCT_NATIVE_SOURCE="%SRC_DIR%\packaging\native"
if errorlevel 1 exit /b 1
cmake --build "%SRC_DIR%\sdk_build" --target TitanAudioLinkJsonSDK
if errorlevel 1 exit /b 1
copy /y "%SRC_DIR%\sdk_build\TitanAudioLinkJsonSDK.dll" "%SRC_DIR%\Titan-Audio-Link-Python-pypi\titan_audio_link\TitanAudioLinkJsonSDK.dll"
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install "%SRC_DIR%\Titan-Audio-Link-Python-pypi" -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
