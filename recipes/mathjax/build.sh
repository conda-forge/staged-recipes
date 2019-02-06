#!/bin/bash
mathjax="$PREFIX/lib/mathjax"
mkdir -p "$mathjax" || exit 1

mv config "$mathjax/" || exit 1
mv docs "$mathjax/" || exit 1
mv extensions "$mathjax/" || exit 1
mv fonts "$mathjax/" || exit 1
mv jax "$mathjax/" || exit 1
mv localization "$mathjax/" || exit 1
mv test "$mathjax/" || exit 1
mv unpacked "$mathjax/" || exit 1

rm *.md ".gitignore" ".npmignore" ".travis.yml" "bower.json" "composer.json" "latest.js" "package.json" || exit 1
cwd="$(pwd)" || exit 1
cp -r "$cwd/." "$mathjax/" || exit 1
cd "$mathjax" || exit 1
rm *.sh LICENSE || exit 1
cd "$cwd" || exit 1

mkdir -p "$PREFIX/bin" || exit 1
cp "${RECIPE_DIR}/.mathjax-post-link.sh" "$PREFIX/bin/" || exit 1
cp "${RECIPE_DIR}/.mathjax-pre-unlink.sh" "$PREFIX/bin/" || exit 1
