echo on

xcopy LICENSE.txt %PREFIX%\

cmake -G"Ninja" -S . -B build ^
    %CMAKE_ARGS% ^
    -DCMAKE_CXX_STANDARD_LIBRARIES=-lxml2 ^
    -DWITH_SWIG=OFF ^
    -DLIBXML_LIBRARY="%PREFIX%"/Library/lib/libxml2.lib ^
    -DLIBXML_INCLUDE_DIR="%PREFIX%"/Library/include/libxml2 ^
    -DENABLE_COMP=ON -DENABLE_FBC=ON -DENABLE_GROUPS=ON ^
    -DENABLE_LAYOUT=ON -DENABLE_MULTI=ON -DENABLE_QUAL=ON ^
    -DENABLE_RENDER=ON -DENABLE_DISTRIB=ON -DENABLE_ARRAYS=ON ^
    -DENABLE_DYN=ON -DENABLE_REQUIREDELEMENTS=ON ^
    -DENABLE_SPATIAL=ON -DWITH_CPP_NAMESPACE=ON

cmake --build build --parallel %CPU_COUNT% --config Release
cmake --build build --target install