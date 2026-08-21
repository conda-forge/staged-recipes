#!/usr/bin/env bash

set -euxo pipefail

cd interfaces/acados_template

# acados_template's setup.py derives its version from setuptools_scm against the
# acados git tree (which is absent from the release tarball) and otherwise falls
# back to its own, older, hard-coded version string.  Pin the wheel metadata to
# the acados release version so it matches the conda package.
"${PYTHON}" - <<'PYEOF'
import os, re
s = open("setup.py").read()
s = re.sub(r"\n\s*setup_requires=\[[^\]]*\],", "", s)
s = re.sub(r"\n\s*use_scm_version=\{.*?\},", "", s, flags=re.DOTALL)
s = re.sub(r"version='[0-9][^']*'", "version='%s'" % os.environ["PKG_VERSION"], s)
open("setup.py", "w").write(s)
PYEOF

${PYTHON} -m pip install . --no-deps --no-build-isolation -vv

# Install activation hooks so ACADOS_SOURCE_DIR points at the conda prefix.
# Without it, acados_template guesses the acados location from its own path
# (three levels up), which is wrong for the site-packages layout, and it would
# fail to find the libraries, headers and the t_renderer binary.
for change in activate deactivate; do
  mkdir -p "${PREFIX}/etc/conda/${change}.d"
  cp "${RECIPE_DIR}/${change}.sh" \
     "${PREFIX}/etc/conda/${change}.d/${PKG_NAME}-${change}.sh"
done
