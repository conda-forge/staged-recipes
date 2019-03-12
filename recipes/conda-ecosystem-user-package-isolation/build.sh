mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d
cp $RECIPE_DIR/activate-user-package-isolation.sh $PREFIX/etc/conda/activate.d/user-package-isolation.sh
cp $RECIPE_DIR/deactivate-user-package-isolation.sh $PREFIX/etc/conda/deactivate.d/user-package-isolation.sh
