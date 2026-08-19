#!/bin/bash
set -euxo pipefail

uwham -h
test -f "$PREFIX/bin/uwham"
test -f "$PREFIX/bin/swham"
test -f "$PREFIX/bin/sreswham"
