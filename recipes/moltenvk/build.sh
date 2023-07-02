#!/bin/sh
set -ex
# This fetch is likely wrong, we should be doing this in the recipe
./fetchDependencies --macos

# https://github.com/KhronosGroup/MoltenVK#hiding-vulkan-api-symbols
make macos \
    MVK_HIDE_VULKAN_SYMBOLS=1

ls -l Package/Latest/MoltenVK/MoltenVK.xcframework

# Try to install the framework???
ls -lah ${PREFIX}
mkdir -p ${PREFIX}/Frameworks
ls -lah ${PREFIX}/Frameworks
cp -a Package/Latest/MoltenVK/MoltenVK.xcframework ${PREFIX}/Frameworks/MoltenVK.xcframework
ls -lah ${PREFIX}/Frameworks
