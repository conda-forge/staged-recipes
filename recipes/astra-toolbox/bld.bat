cd /D %SRC_DIR%
cd python
set VS90COMNTOOLS=%VS140COMNTOOLS%
:: These source directories contain the headers for this project and also for
:: RAPIDXML
set CL=/DASTRA_CUDA /DASTRA_PYTHON "/I%SRC_DIR%\include" "/I%SRC_DIR%\lib\include" "/I%CUDA_PATH%\include"
:: Don't know why, but this copy is necessary
copy "%LIBRARY_LIB%\AstraCuda64.lib" astra.lib
python builder.py build_ext --compiler=msvc install
