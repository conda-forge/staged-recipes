#!/bin/bash
# CLI half of the split: the target-side collector (nsys) plus the docs.
set -euxo pipefail

# 2025.1.3.140 -> 2025.1.3, the directory NVIDIA creates inside the archive.
version_short="${PKG_VERSION%.*}"

# Whether the archive's single top-level directory is stripped during extraction
# differs between the tar.xz and zip artifacts, so locate the payload rather than
# assuming a depth.
payload="$(find . -maxdepth 3 -type d -path "*/nsight-systems/${version_short}" -print -quit)"
if [[ ! -d "${payload}" ]]; then
    echo "could not locate nsight-systems/${version_short} in the extracted archive" >&2
    exit 1
fi
archive_root="$(dirname "$(dirname "${payload}")")"

# The Linux archives ship a full .rpm *and* .deb of the same payload under
# .packages/ (~800 MB of pure duplication). Nothing in the conda package uses them.
rm -rf "${archive_root}/.packages"

# Each Linux archive carries exactly one target-side directory, named for the
# architecture (target-linux-x64 on x86_64, target-linux-sbsa-armv8 on sbsa).
# Globbing keeps this independent of how the build tool exports target_platform.
shopt -s nullglob
target_dirs=("${payload}"/target-linux-*)
shopt -u nullglob
if [[ ${#target_dirs[@]} -ne 1 ]]; then
    echo "expected exactly one target-linux-* directory, found ${#target_dirs[@]}" >&2
    exit 1
fi
target_dir="$(basename "${target_dirs[0]}")"

dest="${PREFIX}/nsight-systems-${version_short}"
mkdir -p "${dest}"
mv "${payload}/${target_dir}" "${dest}/"
mv "${payload}/docs" "${dest}/"

# nsys resolves its bundled libraries through RPATH $ORIGIN, which is computed from
# the *resolved* path, so a relative symlink on PATH is enough.
mkdir -p "${PREFIX}/bin"
ln -s "../nsight-systems-${version_short}/${target_dir}/nsys" "${PREFIX}/bin/nsys"

# about.license_file resolves against the work directory root, which is already
# where LICENSE lands when the archive's top-level directory is stripped.
if [[ ! -f ./LICENSE ]]; then
    cp "${archive_root}/LICENSE" ./LICENSE
fi

# Verify every shipped ELF object against the declared glibc floor
# (c_stdlib_version, see conda_build_config.yaml).
find "${dest}/${target_dir}" -type f \( -name "*.so" -o -name "*.so.*" \) -print0 \
    | xargs -0 check-glibc "${dest}/${target_dir}/nsys"
