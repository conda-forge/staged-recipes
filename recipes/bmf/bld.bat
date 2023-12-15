set CMAKE_GEN=Ninja
set CMAKE_GENERATOR=Ninja
set CMAKE_GENERATOR_PLATFORM=
set CMAKE_GENERATOR_TOOLSET=
set CMAKE_PLAT=

set CMAKE_ARGS=%CMAKE_ARGS% -DBMF_LOCAL_DEPENDENCIES=OFF -DBMF_ENABLE_CUDA=%BMF_BUILD_ENABLE_CUDA% -DHMP_CUDA_ARCH_FLAGS=50-real;52-real;60-real;61-real;70-real;75-real;80-real;86-real;90
"%PYTHON%" -m pip install -v .
if %ERRORLEVEL% neq 0 exit 1

cd %PREFIX%\Lib\site-packages\bmf

: Move tools into environment binary dir
RMDIR /S /Q cmd
DEL /Q bin\test_hmp.exe
DEL /Q bin\hmp_perf_main.exe
COPY bin\* %LIBRARY_BIN%
RMDIR /S /Q bin

: Move headers into environment include dir
XCOPY /E include %LIBRARY_INC%
RMDIR /S /Q include

: Move SDK module libraries into environment library dir
DEL /Q lib\*.exp
DEL /Q lib\_bmf.lib lib\_hmp.lib
COPY lib\*.dll %LIBRARY_BIN%
DEL /Q lib\*.dll
COPY lib\*.lib %LIBRARY_LIB%
DEL /Q lib\*.lib
MOVE BUILTIN_CONFIG.json %LIBRARY_PREFIX%

: Move modules into environment root dir
MOVE cpp_modules %LIBRARY_PREFIX%\cpp_modules
MOVE python_modules %LIBRARY_PREFIX%\python_modules
