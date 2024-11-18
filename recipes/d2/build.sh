set -ex

echo $(which go)
ci/release/build.sh --host-only --install
# ls -lah ./ci/release/build/<version>/d2-<VERSION>-<OS>-<ARCH>.tar.gz
ls -lah ./ci/release/build/


o-licenses save . --save_path ./library_licenses