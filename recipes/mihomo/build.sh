#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CGO_ENABLED=0
export GOFLAGS="${GOFLAGS:-} -tags=with_gvisor"

go build -trimpath \
    -ldflags="-s -w -buildid= -X github.com/metacubex/mihomo/constant.Version=${PKG_VERSION}" \
    -o "${PREFIX}/bin/mihomo"

# go-licenses cannot classify the GPL-3.0-or-later notice used by these
# sagernet forks, or the chacha module (no root LICENSE file).
go-licenses save . --save_path library_licenses \
    --ignore github.com/metacubex/mihomo \
    --ignore github.com/metacubex/chacha \
    --ignore github.com/metacubex/fswatch \
    --ignore github.com/metacubex/sing-mux \
    --ignore github.com/metacubex/sing-quic \
    --ignore github.com/metacubex/sing-shadowsocks \
    --ignore github.com/metacubex/sing-tun \
    --ignore github.com/metacubex/sing-vmess \
    --ignore github.com/metacubex/sing/

copy_mod_license() {
    local module="$1"
    local dest="library_licenses/${module}"
    local src
    src="$(go list -m -f '{{.Dir}}' "${module}")"
    mkdir -p "${dest}"
    cp "${src}/LICENSE" "${dest}/LICENSE"
}

copy_mod_license github.com/metacubex/fswatch
copy_mod_license github.com/metacubex/sing
copy_mod_license github.com/metacubex/sing-mux
copy_mod_license github.com/metacubex/sing-quic
copy_mod_license github.com/metacubex/sing-shadowsocks
copy_mod_license github.com/metacubex/sing-shadowsocks2
copy_mod_license github.com/metacubex/sing-tun
copy_mod_license github.com/metacubex/sing-vmess

chacha_dir="$(go list -m -f '{{.Dir}}' github.com/metacubex/chacha)"
mkdir -p library_licenses/github.com/metacubex/chacha/chachapoly1305
mkdir -p library_licenses/github.com/metacubex/chacha/poly1305
cp "${chacha_dir}/chachapoly1305/LICENSE" library_licenses/github.com/metacubex/chacha/chachapoly1305/LICENSE
cp "${chacha_dir}/poly1305/LICENSE" library_licenses/github.com/metacubex/chacha/poly1305/LICENSE
