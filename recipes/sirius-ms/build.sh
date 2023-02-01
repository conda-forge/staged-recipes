packageName=$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
outdir=$PREFIX/share/$packageName
siriusDistName="sirius"

echo "### ENV INFO"
echo "PREFIX=$PREFIX"
echo "CONDA_PREFIX=$CONDA_PREFIX"
echo "LD_RUN_PATH=$LD_RUN_PATH"
echo "packageName=packageName"
echo "outdir=$outdir"
echo "siriusDistName=$siriusDistName"
echo "### ENV INFO END"


echo "Run gradle build"
./gradlew :sirius_dist:sirius_gui_multi_os:distZip \
    -P "sirius.build.libDir=\$CONDA_PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/lib" \
    -P "build.sirius.native.remove.win=true" \
    -P "build.sirius.native.remove.linux=true" \
    -P "build.sirius.native.remove.mac=true" \
    -P "build.sirius.starter.remove.win=true"

echo "Create package dirs"
mkdir -p "${outdir:?}"
mkdir -p "${PREFIX:?}/bin"

echo "Copy jars"
cp -rp ./sirius_dist/sirius_gui_multi_os/build/install/$siriusDistName/* "${outdir:?}/"
rm -rp "${outdir:?}/bin"

echo "Show jar dir"
ls -lah "$outdir/lib"

echo "Copy starters"
cp -rp ./sirius_dist/sirius_gui_multi_os/build/install/$siriusDistName/bin/* "${PREFIX:?}/bin/"

echo "Show bin dir"
ls -lah "$PREFIX/bin"

echo "Show start script"
ls -lah "$PREFIX/bin/sirius.sh"
cat "$PREFIX/bin/sirius.sh"



#if [[ ${target_platform} =~ linux.* ]]; then
#  mkdir -p $outdir
#  mkdir -p $PREFIX/bin

#  cp -a ./* $outdir/
#  chmod +x $outdir/bin/sirius

#  # remove potentially bundled java runtime
#  rm -r $outdir/lib/runtime
#  # remove jar with bundled ilp solver
#  rm $outdir/lib/app/cbc-java-linux-x86-64-*.jar

#  ls -lah $outdir/lib/app/

#  ln -s $outdir/bin/sirius $PREFIX/bin
#  ln -s $outdir/bin/sirius-gui $PREFIX/bin

#elif [[ ${target_platform} =~ osx.* ]]; then
#  mkdir -p $outdir/Contents
#  mkdir -p $PREFIX/bin

#  cp -a Contents/. $outdir/Contents
#  chmod +x $outdir/Contents/MacOS/sirius

#  # remove potentially bundled java runtime
#  rm -r $outdir/Contents/runtime
#  # remove jar with bundled ilp solver
#  rm $outdir/Contents/app/cbc-java-mac-x86-64-*.jar

#  ls -lah $outdir/Contents/app/

#  ln -s $outdir/Contents/MacOS/sirius $PREFIX/bin
#  ln -s $outdir/Contents/MacOS/sirius-gui $PREFIX/bin
#fi
