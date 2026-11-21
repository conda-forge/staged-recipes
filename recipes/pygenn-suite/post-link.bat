@echo off
setlocal

rem Conda provides %PREFIX% during post-link
set "MSG_FILE=%PREFIX%\.messages.txt"

> "%MSG_FILE%" echo.
>>"%MSG_FILE%" echo ============================================
>>"%MSG_FILE%" echo PyGeNN CUDA backend installed
>>"%MSG_FILE%" echo ============================================
>>"%MSG_FILE%" echo.
>>"%MSG_FILE%" echo To enable CUDA for runtime code generation, set:
>>"%MSG_FILE%" echo     set CUDA_PATH=%%CONDA_PREFIX%%\Library
>>"%MSG_FILE%" echo     set CUDA_LIBRARY_PATH=%%CONDA_PREFIX%%\Library\lib
>>"%MSG_FILE%" echo     set PATH=%%CONDA_PREFIX%%\Library\bin;%%PATH%%
>>"%MSG_FILE%" echo.
>>"%MSG_FILE%" echo To choose a CUDA Toolkit version, install with a conda CUDA constraint, e.g.:
>>"%MSG_FILE%" echo     conda install pygenn cuda-version=12.4
>>"%MSG_FILE%" echo.
>>"%MSG_FILE%" echo Notes:
>>"%MSG_FILE%" echo  - PyGeNN prefers CUDA_LIBRARY_PATH for link-time /LIBPATH discovery on Windows.
>>"%MSG_FILE%" echo  - Verify with:
>>"%MSG_FILE%" echo        nvcc --version
>>"%MSG_FILE%" echo        python -c "import pygenn^&^& print('pygenn import OK')"
>>"%MSG_FILE%" echo ============================================
>>"%MSG_FILE%" echo.

type "%MSG_FILE%"
endlocal
exit /b 0
