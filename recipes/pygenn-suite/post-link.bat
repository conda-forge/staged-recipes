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
>>"%MSG_FILE%" echo CUDA Toolkit version:
>>"%MSG_FILE%" echo     This build is tied to the CUDA Toolkit version it was compiled
>>"%MSG_FILE%" echo     against, and depends on a matching cuda-version. Check with:
>>"%MSG_FILE%" echo         conda list cuda-version
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
