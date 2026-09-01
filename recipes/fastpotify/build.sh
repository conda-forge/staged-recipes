set -euxo pipefail

install_prefix="$PREFIX"
if [[ "$target_platform" == win-* ]]; then
    install_prefix="$LIBRARY_PREFIX"
fi

cargo auditable install --locked --no-track --bins --root "$install_prefix" --path .

mkdir -p "$PREFIX/Menu"
cp "$RECIPE_DIR/menu.json" "$PREFIX/Menu/fastpotify.json"

case "$target_platform" in
    linux-*)
        cp packaging/macos/icon-1024.png "$PREFIX/Menu/fastpotify.png"
        ;;
    osx-*)
        bash packaging/macos/bundle.sh \
            "$PREFIX/bin/fastpotify" Fastpotify.app "$PKG_VERSION"
        cp Fastpotify.app/Contents/Resources/fastpotify.icns \
            "$PREFIX/Menu/fastpotify.icns"
        ;;
    win-*)
        cp packaging/windows/fastpotify.ico "$PREFIX/Menu/fastpotify.ico"
        ;;
esac

cargo-bundle-licenses --format yaml --output ./THIRDPARTY.yml
