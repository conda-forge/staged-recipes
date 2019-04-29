@echo on
mkdir build%vc%
cd build%vc%
cd
cmake -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=ON ..
if errorlevel 1 exit 1
cmake --build . --target install --config Release
cd ..
