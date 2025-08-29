@echo off
setlocal

rem Conda provides %PREFIX% during post-link
set "MSG_FILE=%PREFIX%\.messages.txt"

> "%MSG_FILE%" echo.
>>"%MSG_FILE%" echo ============================================
>>"%MSG_FILE%" echo PyGeNN CUDA backend installed
>>"%MSG_FILE%" echo ============================================
>>"%MSG_FILE%" echo.
>>"%MSG_FILE%" echo To enable CUDA for runtime code generation, set ONE of the following in your shell
>>"%MSG_FILE%" echo pick either the conda environment's modular CUDA or your system CUDA:
>>"%MSG_FILE%" echo.
>>"%MSG_FILE%" echo --- Option A: Use this conda env's modular CUDA ---
>>"%MSG_FILE%" echo     set CUDA_PATH=%%CONDA_PREFIX%%\Library
>>"%MSG_FILE%" echo     set CUDA_LIBRARY_PATH=%%CONDA_PREFIX%%\Library\lib
>>"%MSG_FILE%" echo     set PATH=%%CONDA_PREFIX%%\Library\bin;%%PATH%%
>>"%MSG_FILE%" echo.
>>"%MSG_FILE%" echo --- Option B: Use a system CUDA install (example path) ---
>>"%MSG_FILE%" echo     set CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.x
>>"%MSG_FILE%" echo     set CUDA_LIBRARY_PATH=%%CUDA_PATH%%\lib\x64
>>"%MSG_FILE%" echo     set PATH=%%CUDA_PATH%%\bin;%%PATH%%
>>"%MSG_FILE%" echo.
>>"%MSG_FILE%" echo Notes:
>>"%MSG_FILE%" echo  - PyGeNN prefers CUDA_LIBRARY_PATH for link-time /LIBPATH discovery on Windows.
>>"%MSG_FILE%" echo  - Ensure nvcc and cudart are coherent with your chosen CUDA_PATH.
>>"%MSG_FILE%" echo  - You can verify with:
>>"%MSG_FILE%" echo        nvcc --version
>>"%MSG_FILE%" echo        python -c "import pygenn^&^& print('pygenn import OK')"
>>"%MSG_FILE%" echo ============================================
>>"%MSG_FILE%" echo.

type "%MSG_FILE%"
endlocal
exit /b 0
