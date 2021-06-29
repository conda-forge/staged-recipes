if [[ "${target_platform}" == osx-* ]]; then
    cmake  ${CMAKE_ARGS} -DCMAKE-INSTALL-PREFIX=${PREFIX} .      
elif [[ "${target_platform}" == linux-* ]]; then
    export CXXFLAGS="$CXXFLAGS -std=c++14"
    cmake  ${CMAKE_ARGS} -DCMAKE-INSTALL-PREFIX=${PREFIX} .    
fi
cmake --build . --config release -j${CPU_COUNT}
cmake --install . --config release
