mkdir $PREFIX/opt
mkdir $PREFIX/bin

# Installing emsdk under $CONDA_PREFIX/opt/
mkdir $PREFIX/opt/emsdk
cp -r * $PREFIX/opt/emsdk

# Installing main executable
cp $RECIPE_DIR/emsdk $PREFIX/bin/
