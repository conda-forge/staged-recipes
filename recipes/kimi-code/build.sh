#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Remove upstream prebuilt native addons before building from source
rm -rf packages/pi-tui/native/*/prebuilds

case "${target_platform}" in
    osx-arm64)
        native_platform="darwin"
        native_arch="arm64"
        native_file="darwin-platform.node"
        ;;
    osx-64)
        native_platform="darwin"
        native_arch="x64"
        native_file="darwin-platform.node"
        ;;
    linux-64)
        native_platform="linux"
        native_arch="x64"
        native_file="linux-platform-x11.node"
        ;;
    linux-aarch64)
        native_platform="linux"
        native_arch="arm64"
        native_file="linux-platform-x11.node"
        ;;
    *)
        echo "Unsupported target_platform: ${target_platform}" >&2
        exit 1
        ;;
esac

install_dir="${PREFIX}/lib/node_modules/@moonshot-ai/kimi-code"
native_out="${install_dir}/native/${native_platform}/prebuilds/${native_platform}-${native_arch}/${native_file}"
mkdir -p "$(dirname "${native_out}")"

if [[ "${native_platform}" == "darwin" ]]; then
    "${CC}" \
        -fobjc-arc \
        -std=c11 \
        -Wall \
        -Wextra \
        -Oz \
        -flto \
        -fvisibility=hidden \
        -isysroot "${SDKROOT}" \
        -F"${SDKROOT}/System/Library/Frameworks" \
        -bundle \
        -undefined dynamic_lookup \
        -Wl,-dead_strip \
        -Wl,-x \
        -framework AppKit \
        -framework CoreGraphics \
        -framework Foundation \
        packages/pi-tui/native/darwin/src/darwin-platform.m \
        -o "${native_out}"
else
    "${CC}" \
        -std=c11 \
        -D_GNU_SOURCE \
        -Wall \
        -Wextra \
        -Werror \
        -Os \
        -flto \
        -fPIC \
        -pthread \
        -fvisibility=hidden \
        -fno-stack-protector \
        -shared \
        -nostdlib \
        -Wl,--unresolved-symbols=ignore-all \
        -Wl,--no-as-needed \
        -Wl,-O2 \
        -Wl,--gc-sections \
        -Wl,-z,nodelete \
        -Wl,-s \
        -I"${PREFIX}/include" \
        -L"${PREFIX}/lib" \
        packages/pi-tui/native/linux/src/linux-platform-x11.c \
        -lxcb \
        -o "${native_out}"
fi
chmod 755 "${native_out}"

export NPM_CONFIG_USERCONFIG=/tmp/nonexistent-userrc
export NPM_CONFIG_GLOBALCONFIG=/tmp/nonexistent-globalrc
export npm_config_minimum_release_age=0
export pnpm_config_strict_dep_builds=false
export pnpm_config_manage_package_manager_versions=false
export pnpm_config_ignore_workspace_cycles=true

pnpm install --frozen-lockfile --ignore-scripts

# Build workspace packages and the kimi-code CLI + web assets
pnpm -r --filter './packages/*' run build
pnpm --filter @moonshot-ai/kimi-code run prebuild
pnpm --filter @moonshot-ai/kimi-code exec tsdown
pnpm --filter @moonshot-ai/kimi-code exec tsdown --config tsdown.dist-worker.config.ts
node apps/kimi-code/scripts/check-web-assets.mjs

# Install built CLI assets
cp apps/kimi-code/package.json "${install_dir}/"
cp -R apps/kimi-code/dist "${install_dir}/dist"
cp -R apps/kimi-code/dist-web "${install_dir}/dist-web"
cp LICENSE "${install_dir}/LICENSE"

mkdir -p "${PREFIX}/bin"
tee "${PREFIX}/bin/kimi" << 'EOF'
#!/bin/sh
exec "${CONDA_PREFIX}/bin/node" "${CONDA_PREFIX}/lib/node_modules/@moonshot-ai/kimi-code/dist/main.mjs" "$@"
EOF
chmod +x "${PREFIX}/bin/kimi"

# Generate third-party license disclaimer
pnpm licenses list --json | pnpm-licenses generate-disclaimer --json-input --output-file=ThirdPartyLicenses.txt
