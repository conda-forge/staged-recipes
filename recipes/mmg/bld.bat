cmake -G"NMake Makefiles JOM" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D "CMAKE_INSTALL_PREFIX=%PREFIX%" ^
      -D USE_VTK=OFF ^
      -S . -B build

cd build
devenv mmg.sln /build
