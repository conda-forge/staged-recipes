#!/usr/bin/env bash
set -euo pipefail
source "$RECIPE_DIR/build-env.sh"
jobs=$("$PYTHON" "$RECIPE_DIR/build-jobs.py" bindings-ninja)
"$PYTHON" -m pip install ./engine -vv --no-deps --no-build-isolation \
    --config-settings=setup-args=--wrap-mode=nodownload \
    --config-settings=setup-args=-Depcsaft_build=bindings \
    --config-settings=compile-args=-j"$jobs"
mkdir -p "$SP_DIR/epcsaft/data/packets"
for packet in feos-gross-sadowski-2001 feos-gross-sadowski-2002; do
    mkdir -p "$SP_DIR/epcsaft/data/packets/$packet"
    cp -a "$SRC_DIR/data/packets/$packet/1" "$SP_DIR/epcsaft/data/packets/$packet/"
done
if [[ $target_platform == osx-* ]]; then
    ipopt_library=$(basename "$(otool -D "$IPOPT_PREFIX/lib/libipopt.dylib" | tail -n 1)")
    install -m755 "$IPOPT_PREFIX/lib/$ipopt_library" "$SP_DIR/epcsaft/"
    # The search path Linux sets with patchelf, then an ad hoc signature: dyld refuses an edited arm64 image unsigned.
    for library in "$SP_DIR/epcsaft"/*.so "$SP_DIR/epcsaft"/*.dylib; do
        for path in $(otool -l "$library" | awk '$1 == "cmd" && $2 == "LC_RPATH" {getline; getline; print $2}'); do
            install_name_tool -delete_rpath "$path" "$library"
        done
        install_name_tool -add_rpath @loader_path -add_rpath @loader_path/../../.. "$library"
        codesign -f -s - "$library"
    done
else
    install -m755 "$IPOPT_PREFIX/lib/libipopt.so.3.14.20" "$SP_DIR/epcsaft/"
    ln -s libipopt.so.3.14.20 "$SP_DIR/epcsaft/libipopt.so.3"
    for library in "$SP_DIR/epcsaft"/*.so "$SP_DIR/epcsaft/libipopt.so.3.14.20"; do
        patchelf --set-rpath '$ORIGIN:$ORIGIN/../../..' "$library"
    done
fi
"$PYTHON" "$RECIPE_DIR/licenses.py"
