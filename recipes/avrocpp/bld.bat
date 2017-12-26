#!/bin/bash

mkdir build
cd build

cmake -G "NMake Makefiles" ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DBOOST_ROOT:PATH="%PREFIX%" ^
    -DSNAPPY_ROOT_DIR:PATH="%PREFIX%" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DBUILD_SHARED_LIBS=ON ^
    ..
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
