bash dotnet-install.sh --install-dir $PREFIX/opt/dotnet --version $PKG_VERSION
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d
cp -r $RECIPE_DIR/notwin/activate.d $PREFIX/etc/conda/
cp -r $RECIPE_DIR/notwin/deactivate.d $PREFIX/etc/conda/
cp -r $RECIPE_DIR/common/activate.d $PREFIX/etc/conda/
cp -r $RECIPE_DIR/common/deactivate.d $PREFIX/etc/conda/
