#!/usr/bin/env bash

set -o errexit -o nounset

make
mkdir bin && mv stride bin/
export PATH=${PATH}:"${PWD}/bin"
