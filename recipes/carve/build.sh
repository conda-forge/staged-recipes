if [ "$(uname)" == "Darwin" ]; then
    cmake  ${CMAKE_ARGS} -DCMAKE-INSTALL-PREFIX=${PREFIX} .      
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    cmake  ${CMAKE_ARGS} -DCMAKE-INSTALL-PREFIX=${PREFIX} -DCARVE_BOOST_COLLECTIONS=OFF.    
fi
cmake --build . --config=release
cmake --install . --config=release