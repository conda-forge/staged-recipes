#!/bin/sh

./fetchDependencies --macos

# https://github.com/KhronosGroup/MoltenVK#hiding-vulkan-api-symbols
make macos \
    MVK_HIDE_VULKAN_SYMBOLS=1
ls -l Package/Latest/MoltenVK/MoltenVK.xcframework
