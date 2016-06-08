#!/bin/bash

cd test
qmake-qt5 hello.pro
make
./hello

