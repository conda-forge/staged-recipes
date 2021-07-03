@echo on
mkdir build
if errorlevel 1 exit /B 1
cd build
if errorlevel 1 exit /B 1

qmake ^
    QMAKE_CC=%CC% ^
    QMAKE_CXX=%CXX% ^
    QMAKE_LINK=%CXX% ^
    QMAKE_RANLIB=%RANLIB% ^
    QMAKE_OBJDUMP=%OBJDUMP% ^
    QMAKE_STRIP=%STRIP% ^
    QMAKE_AR="%AR% ^
    ..\texmaker.pro
if errorlevel 1 exit /B 1

jom -j$CPU_COUNT
jom -j%CPU_COUNT%
if errorlevel 1 exit /B 1
jom check
if errorlevel 1 exit /B 1
jom install
