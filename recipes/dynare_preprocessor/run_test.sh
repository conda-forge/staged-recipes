$PREFIX/bin/dynare-preprocessor | grep -q "Missing model file!"
$PREFIX/bin/dynare-preprocessor $RECIPE_DIR/example1.mod | grep -q "Preprocessing completed."
