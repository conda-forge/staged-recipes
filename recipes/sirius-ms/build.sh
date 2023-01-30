outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM

if [[ ${target_platform} =~ linux.* ]] ; then
    mkdir -p $outdir
    mkdir -p $PREFIX/bin

    cp -a ./* $outdir/
    chmod +x $outdir/bin/sirius

    # remove potentially bundled java runtime
    rm -r $outdir/lib/runtime
    # remove jar with bundled ilp solver
    rm $outdir/lib/app/cbc-java-linux-x86-64-*.jar

    ls -lah $outdir/lib/app/

    ln -s $outdir/bin/sirius $PREFIX/bin
    ln -s $outdir/bin/sirius-gui $PREFIX/bin

elif [[ ${target_platform} =~ osx.* ]] ; then
     mkdir -p $outdir/Contents
     mkdir -p $PREFIX/bin

     cp -a Contents/. $outdir/Contents
     chmod +x $outdir/Contents/MacOS/sirius

     # remove potentially bundled java runtime
     rm -r $outdir/Contents/runtime
     # remove jar with bundled ilp solver
     rm $outdir/Contents/app/cbc-java-mac-x86-64-*.jar

     ls -lah $outdir/Contents/app/

     ln -s $outdir/Contents/MacOS/sirius $PREFIX/bin
     ln -s $outdir/Contents/MacOS/sirius-gui $PREFIX/bin
fi