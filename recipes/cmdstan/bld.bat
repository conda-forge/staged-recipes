echo TBB_CXX_TYPE=gcc >> make/local

mingw32-make clean-all
mingw32-make -j4 build

Xcopy -r . %PREFIX%\cmdstan