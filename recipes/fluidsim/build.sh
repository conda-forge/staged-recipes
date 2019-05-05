#!/bin/bash

cat > site.cfg <<EOF
[environ]

EOF

$PYTHON -m pip install --no-deps --ignore-installed -vv .[full]
