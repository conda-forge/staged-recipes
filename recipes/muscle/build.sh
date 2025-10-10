#!/usr/bin/env bash
set -ex

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)
        bash "${SRC_DIR}/src/build_linux.bash"
        ;;
    Darwin*)
        bash "${SRC_DIR}/src/build_osx.bash"
        ;;
    *)
        echo "Unknown OS: ${unameOut}"
        exit 1
        ;;
esac
