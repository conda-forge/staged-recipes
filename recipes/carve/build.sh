cmake  ${CMAKE_ARGS} -DCMAKE-INSTALL-PREFIX=${PREFIX} -DCARVE_BOOST_COLLECTIONS=OFF . 
cmake --build . --config=release
cmake --install . --config=release