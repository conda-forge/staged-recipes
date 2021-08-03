@echo on
mkdir build
if errorlevel 1 exit /B 1
cd build
if errorlevel 1 exit /B 1

qmake QMAKE_CC=%CC% QMAKE_CXX=%CXX% ..\libQGLViewer-%PKG_VERSION%.pro
if errorlevel 1 exit /B 1

jom -j%CPU_COUNT%
if errorlevel 1 exit /B 1
jom check
if errorlevel 1 exit /B 1

cd ..
COPY QGLViewer\QGLViewer2.dll %LIBRARY_BIN%
COPY QGLViewer\QGLViewer2.lib %LIBRARY_LIB%
mkdir  %LIBRARY_INC%\QGLViewer
COPY QGLViewer\*.h %LIBRARY_INC%\QGLViewer
mkdir  %LIBRARY_INC%\QGLViewer\VRender
COPY QGLViewer\VRender\*.h %LIBRARY_INC%\QGLViewer\VRender
