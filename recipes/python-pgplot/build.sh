#!/bin/bash

set -euxo pipefail

cd ${SRC_DIR}

# Build and install the package
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation

# Test that the extension was built correctly
${PYTHON} -c "import ppgplot; print('python-pgplot extension imported successfully')"
${PYTHON} -c "import ppgplot._ppgplot; print('C extension module loaded successfully')"
