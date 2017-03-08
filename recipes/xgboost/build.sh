if [ -n "${OSX_ARCH+x}" ]; then
  patch xgboost/Makefile $RECIPE_DIR/Makefile.patch
  patch xgboost/build-python.sh $RECIPE_DIR/build-python.patch
fi
cp $RECIPE_DIR/LICENSE LICENSE
$PYTHON setup.py install --single-version-externally-managed --record record.txt
