set -euxo pipefail

pnpm install --ignore-scripts
npm run build
export CFLAGS="${CFLAGS:-} -D_BSD_SOURCE -D_DEFAULT_SOURCE"

( cd codegraph-kernel && cargo build --release )

mkdir -p kernel
# conda-forge's rust compiler activation sets a target-triple-specific
# cargo output dir (target/<triple>/release/), not plain target/release/
# -- find rather than assume the path so this works whichever triple
# the host build resolves to.
KERNEL_LIB=$(find codegraph-kernel/target -maxdepth 3 \( -name "libcodegraph_kernel.so" -o -name "libcodegraph_kernel.dylib" \) -print -quit)
[ -n "$KERNEL_LIB" ] || { echo "error: built codegraph-kernel library not found under codegraph-kernel/target" >&2; exit 1; }
cp "$KERNEL_LIB" kernel/codegraph-kernel.node

export npm_config_prefix="${PREFIX}"
npm pack --ignore-scripts
npm install --global "${SRC_DIR}/colbymchenry-codegraph-${PKG_VERSION}.tgz"

INSTALLDIR="${PREFIX}/lib/node_modules/@colbymchenry/codegraph"
mkdir -p "${INSTALLDIR}/kernel"
cp kernel/codegraph-kernel.node "${INSTALLDIR}/kernel/codegraph-kernel.node"
find "${INSTALLDIR}/node_modules" -type d -name .bin -exec rm -rf {} +

( cd codegraph-kernel && cargo-bundle-licenses --format yaml --output THIRDPARTY.yml )
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt