cmake -S . -B build ^
      -G "Ninja" ^
      -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
      -DCMAKE_LIBRARY_PATH="%PREFIX%\lib" ^
      -DCMAKE_INCLUDE_PATH="%PREFIX%\include" ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_CXX_STANDARD=17 ^
      -DBoost_NO_BOOST_CMAKE=ON ^
      -DBUILD_SHARED_LIBS=ON ^
      -DSFCGAL_BUILD_TESTS=OFF ^
      -DCMAKE_CXX_FLAGS="/bigobj /EHsc /DBOOST_THROW_EXCEPTION_NO_SOURCE_LOCATION" ^
      -DSFCGAL_EXPORTS=ON ^
      -Wno-dev

cmake --build build --config Release
cmake --install build

