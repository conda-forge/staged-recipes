setlocal EnableDelayedExpansion

mkdir build
cd build

rem The Python lib has no period in the
rem version string, so we remove it here.
set PY_VER_NO_DOT=%PY_VER:.=%

cmake ..\tools\python -LAH -G"NMake Makefiles"              ^
-DCMAKE_BUILD_TYPE="Release"                                ^
-DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"                      ^
-DBoost_USE_STATIC_LIBS=0                                   ^
-DBoost_USE_STATIC_RUNTIME=0                                ^
-DBOOST_ROOT="%LIBRARY_PREFIX%"                             ^
-DBOOST_INCLUDEDIR="%LIBRARY_INC%"                          ^
-DBOOST_LIBRARYDIR="%LIBRARY_BIN%"                          ^
-DPYTHON3=%PY3K%                                            ^
-DPYTHON_LIBRARY="%PREFIX%\libs\python%PY_VER_NO_DOT%.lib"  ^
-DPYTHON_INCLUDE_DIR="%PREFIX%\include"                     ^
-DDLIB_LINK_WITH_SQLITE3=0                                  ^
-DDLIB_PNG_SUPPORT=1                                        ^
-DPNG_INCLUDE_DIR="%LIBRARY_INC%"                           ^
-DPNG_PNG_INCLUDE_DIR="%LIBRARY_INC%"                       ^
-DPNG_LIBRARY="%LIBRARY_BIN%/libpng16.dll"                  ^
-DZLIB_INCLUDE_DIRS="%LIBRARY_INC%"                         ^
-DZLIB_LIBRARIES="%LIBRARY_BIN%/zlib.dll"                   ^
-DDLIB_JPEG_SUPPORT=1                                       ^
-DJPEG_INCLUDE_DIR="%LIBRARY_INC%"                          ^
-DJPEG_LIBRARY="%LIBRARY_BIN%/libjpeg.dll"                  ^
-DDLIB_NO_GUI_SUPPORT=1                                     ^
-DDLIB_USE_BLAS=0                                           ^
-DDLIB_USE_LAPACK=0                                         ^
-DUSE_SSE2_INSTRUCTIONS=1                                   ^
-DUSE_SSE4_INSTRUCTIONS=0                                   ^
-DUSE_AVX_INSTRUCTIONS=0                                    ^
-DDLIB_USE_CUDA=0                                           ^
-DDLIB_GIF_SUPPORT=0

cmake --build . --config Release --target INSTALL

rem Copy the dlib library to site packages
move "..\python_examples\dlib.pyd" "%SP_DIR%\dlib.pyd"
