cp $RECIPE_DIR/sqlite_amalgamation/sqlite3.c $SRC_DIR/sqlite3.c
cp $RECIPE_DIR/sqlite_amalgamation/sqlite3.h $SRC_DIR/sqlite3.h

$PYTHON setup.py build_static build
$PYTHON setup.py install