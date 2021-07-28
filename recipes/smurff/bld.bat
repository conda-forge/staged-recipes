REM SET "CMAKE_ARGS=-DENABLE_MKL=ON -DBoost_COMPILER=-vc140 -DCMAKE_INSTALL_PREFIX=%PREFIX%"
SET "CMAKE_ARGS=-DENABLE_MKL=ON -DCMAKE_INSTALL_PREFIX=%PREFIX%"

REM conda build sets "Visual Studio 15 2017 Win64" generator
REM conda forge sets "NMake Makefiles" generator
REM both are incompatible with "-A x64" that we add ourselves in setup.py,
REM FIXME!
SET "CMAKE_GENERATOR=Visual Studio 14 2015"

%PYTHON% setup.py install ^
    --install-binaries ^
    --single-version-externally-managed --record=record.txt