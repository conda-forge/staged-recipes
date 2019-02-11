@echo on

@rem The `vs2015_win-64` compiler activate package sets CFLAGS and CXXFLAGS
@rem to "-MD -GL".  Unfortunately that causes a huge ballooning in static
@rem library size (more than 100MB per .lib file).  Unsetting those flags
@rem simply works.

set CFLAGS=
set CXXFLAGS=

mkdir build-cpp
if errorlevel 1 exit 1

cd build-cpp

cmake ..  ^
      -GNinja ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH=%CONDA_PREFIX% ^
      -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
      -DgRPC_CARES_PROVIDER="package" ^
      -DgRPC_GFLAGS_PROVIDER="package" ^
      -DgRPC_PROTOBUF_PROVIDER="package" ^
      -DgRPC_SSL_PROVIDER="package" ^
      -DgRPC_ZLIB_PROVIDER="package"

cmake --build . --config Release --target install

if errorlevel 1 exit 1
