set -ex

dynare-preprocessor | grep -q "Missing model file!"
dynare-preprocessor $RECIPE_DIR/example1.mod | grep -q "Preprocessing completed."
