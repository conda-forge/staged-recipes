set CFG=Release
:: set CMAKE_GENERATOR=Visual Studio 16 2019
pushd src
  cmake -G"%CMAKE_GENERATOR%"  ^
        -DCMAKE_BUILD_TYPE=%CFG%  ^
        -DCMAKE_INSTALL_PREFIX=%PREFIX%  ^
        -DCMAKE_CXX_FLAGS=-DNO_WIN32_BM  ^
        .
  if not ErrorLevel 0 exit /b 1
  cmake --build . --config %CFG%
  if not ErrorLevel 0 exit /b 1
popd
mkdir %PREFIX%\data
robocopy data %PREFIX%\data /e /xo /it
dir .
