cmake -DCMAKE-INSTALL-PREFIX="%LIBRARY_PREFIX%" ..\. 
cmake --build . --config=release
cmake --install . --config=release