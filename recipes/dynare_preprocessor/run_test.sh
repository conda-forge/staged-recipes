set -ex

dynare-preprocessor | grep -q "Missing model file!"
dynare-preprocessor example1.mod | grep -q "Preprocessing completed."
