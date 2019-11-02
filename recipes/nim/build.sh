#!/usr/bin/env bash

# http://ix.io/1X9Y/bash
# Running this script will download and extract nim installation to ${PREFIX}.

set -vexu -o pipefail
IFS=$'\n\t'
# http://redsymbol.net/articles/unofficial-bash-strict-mode


nim_version="${NIM_VERSION:-1.0.2}"
nim_archive_url="https://nim-lang.org/download/nim-${nim_version}-linux_x64.tar.xz"

nim_download_dir="$(pwd)/nim-${nim_version}"

echo "Downloading nim archive from ${nim_archive_url} .."
curl -RLs "${nim_archive_url}" -o "nim.tar.xz"
tar xf nim.tar.xz # Extracts to ${nim_download_dir}.
ls -larth ${nim_download_dir}

mkdir -p "${PREFIX}"
cd "${PREFIX}" || exit
rsync -av "${nim_download_dir}"/bin .
rsync -av "${nim_download_dir}"/lib .
rsync -av "${nim_download_dir}"/config .
rsync -av "${nim_download_dir}"/copying.txt LICENSE

echo "Nim ${nim_version} has been downloaded and extracted to ${PREFIX}/."
