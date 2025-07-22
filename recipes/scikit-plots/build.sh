#!/bin/bash

# Inspired by the numpy-feedstock build script:
# https://github.com/conda-forge/numpy-feedstock/blob/main/recipe/build.sh

set -ex

git_fetch_shallow() {
  local repo_url="$1"
  local tag="$2"

  if [[ -z "$repo_url" || -z "$tag" ]]; then
    echo "Usage: git_fetch_shallow <repo_url> <tag>"
    return 1
  fi
  echo -e "\033[1;34m[INFO]\033[0m Cloning $repo_url @ $tag (shallow + submodules)..."
  # Initialize the git repository (if not done already)
  git init .
  # Add the remote origin URL
  git remote add origin "$repo_url"
  # Fetch the tags from the remote repository
  # git fetch --depth 1 origin "$tag"
  git fetch --tags
  # Checkout the desired tag
  # git checkout FETCH_HEAD
  git checkout "$tag"
  # Initialize and update the submodules
  git submodule update --init --recursive
  # Install and pull LFS files for the repository and submodules
  # git lfs install
  # git lfs pull
  echo -e "\033[1;32m[SUCCESS]\033[0m Repo and submodules fetched successfully."
}
# git_fetch_shallow https://github.com/scikit-plots/scikit-plots.git v0.4.0rc4

# Initialize and update the submodules
git submodule update --init --recursive || true

mkdir builddir

# HACK: extend $CONDA_PREFIX/meson_cross_file that's created in
# https://github.com/conda-forge/ctng-compiler-activation-feedstock/blob/main/recipe/activate-gcc.sh
# https://github.com/conda-forge/clang-compiler-activation-feedstock/blob/main/recipe/activate-clang.sh
# to use host python; requires that [binaries] section is last in meson_cross_file
echo "python = '${PREFIX}/bin/python'" >> ${CONDA_PREFIX}/meson_cross_file.txt

# meson-python already sets up a -Dbuildtype=release argument to meson, so
# we need to strip --buildtype out of MESON_ARGS or fail due to redundancy
MESON_ARGS_REDUCED="$(echo $MESON_ARGS | sed 's/--buildtype release //g')"

# -wnx flags mean: --wheel --no-isolation --skip-dependency-check
$PYTHON -m build -w -n -x \
    -Cbuilddir=builddir \
    -Csetup-args=${MESON_ARGS_REDUCED// / -Csetup-args=} \
    || (cat builddir/meson-logs/meson-log.txt && exit 1)

pip install dist/*.whl