REM SET "CMAKE_ARGS=-DENABLE_MKL=ON -DBoost_COMPILER=-vc140 -DCMAKE_INSTALL_PREFIX=%PREFIX%"
SET "CMAKE_ARGS=-DENABLE_MKL=ON -DCMAKE_INSTALL_PREFIX=%PREFIX%"

REM conda build sets "Visual Studio 15 2017 Win64" generator
REM which is incompatible with "-A x64" that we add ourselves in setup.py,
REM hence we remove " Win64"
SET "CMAKE_GENERATOR=%CMAKE_GENERATOR: Win64=%"

%PYTHON% setup.py install ^
    --install-binaries ^
    --single-version-externally-managed --record=record.txt