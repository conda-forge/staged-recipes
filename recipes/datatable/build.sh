#!/bin/bash

set -euo pipefail

{

cat >fake-git <<'EOF'
#!/bin/bash

echo "FAKE_BUILD_INFO_FOR_CONDA"
EOF

chmod +x fake-git
mv fake-git git
env PATH=.:"$PATH" "$PYTHON" ci/ext.py build
mv git fake-git
"$PYTHON" -m pip install . -vv
}
