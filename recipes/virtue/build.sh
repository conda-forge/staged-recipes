#!/bin/bash
# Add SKILL library
mkdir -p "${PREFIX}/lib/skill/virtue"
cp -rf "${RECIPE_DIR}/../virtue" \
       "${PREFIX}/lib/skill/"
# Not included in the sdist
#for item in "README.md" "pyproject.toml"; do
#    cp -rf "${RECIPE_DIR}/../${item}" \
#           "${PREFIX}/lib/skill/virtue"
#done

# Copy the activate scripts to $PREFIX/etc/conda/activate.d.
# This will allow them to be run on environment activation.
mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
cp "${RECIPE_DIR}/activate.sh" \
   "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
cp "${RECIPE_DIR}/activate.csh" \
   "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.csh"

flit build
python -m pip install --no-deps dist/*.whl -vv