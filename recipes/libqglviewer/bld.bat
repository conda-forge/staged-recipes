@echo on
mkdir build
if errorlevel 1 exit /B 1
cd build
if errorlevel 1 exit /B 1

qmake QMAKE_CC=%CC% QMAKE_CXX=%CXX% ..\libQGLViewer-$PKG_VERSION.pro
if errorlevel 1 exit /B 1

jom -j%CPU_COUNT%
if errorlevel 1 exit /B 1
jom check
if errorlevel 1 exit /B 1
jom install
