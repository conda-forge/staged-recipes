#!/usr/bin/env bash
set -ex

mkdir -p "${PREFIX}/bin"
sed -i"" -E -e "1s|/usr/bin/perl( -w)?|/usr/bin/env perl|" "flamegraph.pl"
install -m 0755 "flamegraph.pl" "${PREFIX}/bin/flamegraph"
