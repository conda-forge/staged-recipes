#!/bin/bash
set -e
echo "Using PKG_VERSION: $PKG_VERSION"

cp ${RECIPE_DIR}/drop_packages.py drop_packages.py
cp ${RECIPE_DIR}/recipe.yaml recipe.yaml

cp recipe.yaml recipe.yaml.backup

${PYTHON} drop_packages.py "$PKG_VERSION"

if ! diff -q recipe.yaml.backup recipe.yaml > /dev/null 2>&1; then
    echo "Error: recipe.yaml was modified by drop_packages.py"
    echo ""
    echo "Changes detected:"
    diff recipe.yaml.backup recipe.yaml || true
    echo ""
    echo "The recipe.yaml file should be up-to-date. Please run:"
    echo "  ${PYTHON} drop_packages.py $PKG_VERSION"
    echo "  git add recipe.yaml"
    echo "  git commit -m 'Update minimum versions'"
    mv recipe.yaml.backup recipe.yaml
    exit 1
fi

rm recipe.yaml.backup
echo "recipe.yaml is up-to-date"
