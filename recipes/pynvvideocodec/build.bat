@echo on

set "FFMPEG_DIR=%LIBRARY_PREFIX%"
set "DLPACK_SOURCE_DIR=%LIBRARY_PREFIX%"
set USE_NVTX=0
set CMAKE_GENERATOR=Ninja
set CMAKE_BUILD_PARALLEL_LEVEL=%CPU_COUNT%
set "CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_CUDA_ARCHITECTURES=%CUDAARCHS%"

:: Ensure the build cannot accidentally use the precompiled FFmpeg distribution.
if exist external\ffmpeg rmdir /s /q external\ffmpeg
if errorlevel 1 exit 1

"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
