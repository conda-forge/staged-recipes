$PYTHON -m pip install semgrep==${PKG_VERSION} -t . --upgrade --no-deps
# Explanation of arguments:
# -t .      # install in this target directory
# --upgrade # force pip to update existing "semgrep" directory
# --no-deps # via https://docs.conda.io/projects/conda-build/en/latest/user-guide/wheel-files.html

$PYTHON -m pip install . -vv
# the above is from Grayskull's output