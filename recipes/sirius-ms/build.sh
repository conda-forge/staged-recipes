packageName=$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
outdir=$PREFIX/share/$packageName
siriusDistName="sirius"

echo "### BUILD ENV INFO"
echo "PREFIX=$PREFIX"
echo "CONDA_PREFIX=$CONDA_PREFIX"
echo "LD_RUN_PATH=$LD_RUN_PATH"
echo "packageName=$packageName"
echo "outdir=$outdir"
echo "siriusDistName=$siriusDistName"
echo "### BUILD ENV INFO END"

echo "### Show Build dir"
ls -lah ./

echo "### Run gradle build"
./gradlew :sirius_dist:sirius_gui_multi_os:installDist \
    -P "build.sirius.location.lib=\$CONDA_PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/lib" \
    -P "build.sirius.native.remove.win=true" \
    -P "build.sirius.native.remove.linux=true" \
    -P "build.sirius.native.remove.mac=true" \
    -P "build.sirius.starter.remove.win=true"

echo "### Create package dirs"
mkdir -p "${outdir:?}"
mkdir -p "${PREFIX:?}/bin"

echo "### Copy jars"
cp -rp ./sirius_dist/sirius_gui_multi_os/build/install/$siriusDistName/* "${outdir:?}/"
rm -r "${outdir:?}/bin"

echo "### Show jar dir"
ls -lah "$outdir/lib"

echo "### Copy starters"
cp -rp ./sirius_dist/sirius_gui_multi_os/build/install/$siriusDistName/bin/* "${PREFIX:?}/bin/"

echo "### Show bin dir"
ls -lah "$PREFIX/bin"

echo "### Show start script"
ls -lah "$PREFIX/bin/sirius.sh"
cat "$PREFIX/bin/sirius.sh"
