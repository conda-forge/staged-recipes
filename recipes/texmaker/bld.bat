qmake -set prefix %PREFIX%

qmake ^
    QMAKE_CC=%CC% ^
    QMAKE_CXX=%CXX% ^
    QMAKE_LINK=%CXX% ^
    QMAKE_RANLIB=%RANLIB% ^
    QMAKE_OBJDUMP=%OBJDUMP% ^
    QMAKE_STRIP=%STRIP% ^
    QMAKE_AR="%AR% ^
    texmaker.pro

make -j$CPU_COUNT
make install PREFIX=$PREFIX
