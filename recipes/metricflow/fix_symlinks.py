"""Materialize the sdist's broken-on-Windows symlinked test fixtures.

Upstream's sdist ships 13 test-fixture files as symlinks (each
metricflow_semantics/test_helpers/semantic_manifest_yamls/*/project_configuration.yaml
points at .../shared/project_configuration.yaml). That resolves fine on
Linux/macOS, but breaks the win-64 build: hatchling's wheel builder calls
os.stat() on every included file while walking the tree, and Windows'
handling of these tar-extracted symlinks makes that raise WinError 123
("invalid filename syntax"). Replace them with real file copies instead of
relying on symlink support -- this produces the same bytes a working Unix
build already gets (verified against upstream's own published wheel).
"""

import glob
import os
import shutil

SHARED = "metricflow_semantics/test_helpers/semantic_manifest_yamls/shared/project_configuration.yaml"
PATTERN = "metricflow_semantics/test_helpers/semantic_manifest_yamls/*/project_configuration.yaml"

targets = [p for p in glob.glob(PATTERN) if os.path.normpath(p) != os.path.normpath(SHARED)]
for target in targets:
    if os.path.lexists(target):
        os.remove(target)
    shutil.copyfile(SHARED, target)
