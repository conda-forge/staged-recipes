if [[ "${target_platform}" == osx-* ]]; then
    cmake  ${CMAKE_ARGS} .      
elif [[ "${target_platform}" == linux-* ]]; then
    export CXXFLAGS="$CXXFLAGS -std=c++14"
    cmake  ${CMAKE_ARGS} .    
fi
cmake --build . --config release -j${CPU_COUNT}
cmake --install . --config release
