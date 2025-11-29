#!/usr/bin/env bash
set -ex

mkdir -p "${PREFIX}/bin"
sed -i"" -e "1s|/usr/bin/perl|${PREFIX}/bin/perl|" "flamegraph.pl"
install -m 0755 "flamegraph.pl" "${PREFIX}/bin/flamegraph"
