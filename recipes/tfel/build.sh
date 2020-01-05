mkdir build
cd build
cmake -G "$CMAKE_GENERATOR" -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} ../ -DCMAKE_BUILD_TYPE=Release -Denable-developer-warnings=ON -Denable-random-tests=OFF -Dlocal-castem-header=ON -Denable-fortran=ON -Denable-python=ON -Denable-python-bindings=ON -DBOOST_ROOT=${PREFIX} -DBoost_USE_STATIC_LIBS=OFF -DBoost_DEBUG=ON -DBoost_DETAILED_FAILURE_MESSAGE=ON -DBOOST_INCLUDEDIR=${PREFIX}/include -DBOOST_LIBRARYDIR=${PREFIX}/lib -DBoost_NO_SYSTEM_PATHS=OFF -DBoost_NO_BOOST_CMAKE=ON -Denable-java=OFF -Denable-aster=ON -Denable-abaqus=ON -Denable-calculix=ON -Denable-comsol=ON -Denable-diana-fea=ON -Denable-ansys=ON -Denable-europlexus=ON -Denable-zmat=OFF -Denable-cyrano=ON -Denable-lsdyna=ON -Denable-cadna=OFF -Denable-website=OFF -Denable-reference-doc=OFF -Denable-doxygen-doc=OFF -DCMAKE_EXPORT_COMPILE_COMMANDS=OFF  -DCMAKE_INSTALL_PREFIX=$PREFIX
cmake --build . --target all
cmake --build . --target install

