mkdir $PREFIX/songexplorer
cp -R $SRC_DIR/* $PREFIX/songexplorer
mkdir $PREFIX/bin
executables=(songexplorer accuracy activations classify cluster compare congruence ensemble ethogram freeze generalize loop misses mistakes time-freq-threshold.py train xvalidate)
for executable in ${executables[*]}; do
    ln -s $PREFIX/songexplorer/src/$executable $PREFIX/bin/$executable
done
ln -s $PREFIX/songexplorer/test/runtests $PREFIX/bin/runtests
