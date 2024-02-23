#!/bin/bash
if [ "$(uname)" == "Darwin" ]; then
    echo "Installing KPop for OSX."
else 
    echo "Installing KPop for Linux"
fi

mkdir -p $PREFIX/bin
cp $SRC_DIR/bin/KPop* $PREFIX/bin
cp $SRC_DIR/bin/FASTools $PREFIX/bin
cp $SRC_DIR/bin/Parallel $PREFIX/bin

chmod +x $PREFIX/bin/
chmod +x $PREFIX/bin/KPop*
chmod +x $PREFIX/bin/FASTools
chmod +x $PREFIX/bin/Parallel