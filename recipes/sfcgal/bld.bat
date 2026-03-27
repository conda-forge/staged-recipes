cmake -S . -B build ^
      -G "Ninja" ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DCMAKE_LIBRARY_PATH="%LIBRARY_LIB%" ^
      -DCMAKE_INCLUDE_PATH="%LIBRARY_INC%" ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_CXX_STANDARD=17 ^
      -DBoost_NO_BOOST_CMAKE=ON ^
      -DBoost_USE_STATIC_LIBS=OFF ^
      -DBUILD_SHARED_LIBS=OFF ^
      -DSFCGAL_USE_STATIC_LIBS=ON ^
      -DSFCGAL_BUILD_TESTS=OFF ^
      -DCMAKE_CXX_FLAGS="/bigobj /EHsc /DBOOST_THROW_EXCEPTION_NO_SOURCE_LOCATION" ^
      -DCGAL_USE_GMPXX=OFF ^
      -Wno-dev

cmake --build build --config Release
cmake --install build

