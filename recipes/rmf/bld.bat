mkdir build
cd build

:: We use conda's boost, which includes zlib support, but defining
:: BOOST_ALL_DYN_LINK makes boost try to link against boost_zlib*.lib,
:: which doesn't exist. Override this by explicitly naming the boost library
:: to link against - since there isn't one, link against kernel32 instead
:: (which pretty much everything links against, so this doesn't introduce
:: an extra dependency)

cmake -DCMAKE_BUILD_TYPE=Release ^
      -G Ninja ^
      -DCMAKE_PREFIX_PATH=%PREFIX:\=/% ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX:\=/% ^
      -DCMAKE_INSTALL_LIBDIR=bin ^
      -DCMAKE_INSTALL_PYTHONDIR=%SP_DIR:\=/% ^
      -DCMAKE_CXX_FLAGS="/DBOOST_ALL_DYN_LINK /EHsc /D_HDF5USEDLL_ /DH5_BUILT_AS_DYNAMIC_LIB /DWIN32 /bigobj /DBOOST_ZLIB_BINARY=kernel32" ^
      ..
if errorlevel 1 exit 1

ninja install -j%CPU_COUNT%
if errorlevel 1 exit 1
