@echo off

set R=%SRC_DIR%

set B_VC=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\
rem call "%B_VC%\vcvars64.bat" amd64 8.1 -vcvars_ver=14.0

set B_BV=1_69
set B_BOOST=E:\wjp\boost_%B_BV%_0

cd /D "%B_BOOST%\lib64-msvc-14.0"

mkdir "%R%\lib\x64"
mkdir "%R%\bin\x64\Release_CUDA"

copy boost_unit_test_framework-vc140-mt-x64-%B_BV%.lib %R%\lib\x64
copy libboost_chrono-vc140-mt-x64-%B_BV%.lib %R%\lib\x64
copy libboost_date_time-vc140-mt-x64-%B_BV%.lib %R%\lib\x64
copy libboost_system-vc140-mt-x64-%B_BV%.lib %R%\lib\x64
copy libboost_thread-vc140-mt-x64-%B_BV%.lib %R%\lib\x64

cd %B_BOOST%

xcopy /i /e /q /y boost "%R%\lib\include\boost"

cd /D %R%

cd python

set VS90COMNTOOLS=%VS140COMNTOOLS%
set CL=/DASTRA_CUDA /DASTRA_PYTHON "/I%R%\include" "/I%R%\lib\include" "/I%CUDA_PATH%\include"
copy "%CONDA_PREFIX%\Library\lib\AstraCuda64.lib" astra.lib
python builder.py build_ext --compiler=msvc install
