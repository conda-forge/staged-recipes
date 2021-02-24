@REM Not testing in Windows because the MSVC compiler v14.1 in conda-forge cause linking errors due to a bug in it.
@REM cd test
@REM mkdir build
@REM cd build
@REM cmake .. -GNinja -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%
@REM ninja
@REM test.exe
