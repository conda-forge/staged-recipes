cmake  ${CMAKE_ARGS} -DCMAKE-INSTALL-PREFIX=${PREFIX} . 
cmake --build . --config=release
cmake --install . --config=release