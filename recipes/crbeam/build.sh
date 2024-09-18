#!/bin/bash
mv *.h src/external/nr/
cmake src/app/crbeam
make
cp CRbeam  $PREFIX/bin/crbeam
mkdir -p $PREFIX/share/crbeam/
cp -R bin/tables $PREFIX/share/crbeam/
#cp $RECIPE_DIR/us_states.yaml $PREFIX/share/intake/
