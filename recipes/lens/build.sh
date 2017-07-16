
# export LENSDIR=$PREFIX/lib

export HOSTTYPE=x86_64-linux

cd TclTk/tcl8.3.4/unix
rm config.cache
./configure --enable-shared --enable-64bit
make
rm -f *.o

cd ../../tk8.3.4/unix
rm config.cache
./configure --enable-shared --enable-64bit --with-tcl=../../tcl8.3.4/unix
make
rm -f *.o

cd $SRC_DIR

mkdir Bin/$HOSTTYPE
mv TclTk/tcl8.3.4/unix/libtcl8.3.* Bin/${HOSTTYPE}
mv TclTk/tk8.3.4/unix/libtk8.3.* Bin/${HOSTTYPE}


cd $SRC_DIR
make all

# remove synlinks before copy
rm alens lens Bin/x86_64-linux/alens Bin/x86_64-linux/lens

mkdir -p $PREFIX/lib/Lens
cp -R * $PREFIX/lib/Lens

cp ./Bin/x86_64-linux/lens-* $PREFIX/bin/lens
cp ./Bin/x86_64-linux/libtcl8.3.* $PREFIX/lib
cp ./Bin/x86_64-linux/libtk8.3.* $PREFIX/lib
cp ./TclTk/tcl8.3.4/library/init.tcl $PREFIX/lib/init.tcl

# export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${LENSDIR}/Bin/${HOSTTYPE}


# export PATH=${PATH}:${LENSDIR}/Bin/${HOSTTYPE}
mkdir -p $PREFIX/etc/conda/activate.d
cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/lens.sh
