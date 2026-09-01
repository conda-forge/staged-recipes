#!/bin/bash
# GUI half of the split: the Qt-based nsys-ui timeline viewer.
set -euxo pipefail

# 2025.1.3.140 -> 2025.1.3, the directory NVIDIA creates inside the archive.
version_short="${PKG_VERSION%.*}"

payload="$(find . -maxdepth 3 -type d -path "*/nsight-systems/${version_short}" -print -quit)"
if [[ ! -d "${payload}" ]]; then
    echo "could not locate nsight-systems/${version_short} in the extracted archive" >&2
    exit 1
fi
archive_root="$(dirname "$(dirname "${payload}")")"

# See build_cli.sh: ~800 MB of duplicated rpm/deb payload.
rm -rf "${archive_root}/.packages"

# Exactly one host-side directory per archive (host-linux-x64 on x86_64,
# host-linux-armv8 on sbsa). See build_cli.sh for why this is globbed.
shopt -s nullglob
host_dirs=("${payload}"/host-linux-*)
shopt -u nullglob
if [[ ${#host_dirs[@]} -ne 1 ]]; then
    echo "expected exactly one host-linux-* directory, found ${#host_dirs[@]}" >&2
    exit 1
fi
host_dir="$(basename "${host_dirs[0]}")"

# Shares an install root with nsight-systems-cli, which owns target-*/ and docs/.
dest="${PREFIX}/nsight-systems-${version_short}"
mkdir -p "${dest}"
mv "${payload}/${host_dir}" "${dest}/"

mkdir -p "${PREFIX}/bin"
ln -s "../nsight-systems-${version_short}/${host_dir}/nsys-ui" "${PREFIX}/bin/nsys-ui"

# about.license_file resolves against the work directory root, which is already
# where LICENSE lands when the archive's top-level directory is stripped.
if [[ ! -f ./LICENSE ]]; then
    cp "${archive_root}/LICENSE" ./LICENSE
fi

find "${dest}/${host_dir}" -type f \( -name "*.so" -o -name "*.so.*" \) -print0 \
    | xargs -0 check-glibc "${dest}/${host_dir}/nsys-ui"
