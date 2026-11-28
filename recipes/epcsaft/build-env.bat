@echo off
set CC=clang-cl
set CXX=clang-cl
set CFLAGS=/MD /fp:precise /clang:-ffp-contract=off
set CXXFLAGS=/MD /fp:precise /clang:-ffp-contract=off
set PKG_CONFIG_PATH=%LIBRARY_PREFIX%\lib\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig
set PATH=%PREFIX%\bin;%LIBRARY_PREFIX%\bin;%PATH%
