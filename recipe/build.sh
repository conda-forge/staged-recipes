cat > site.cfg <<EOF
[DEFAULT]
library_dirs = $PREFIX/lib
include_dirs = $PREFIX/include
EOF
$PYTHON -m pip install --no-deps --ignore-installed .
