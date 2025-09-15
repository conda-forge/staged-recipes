#!/usr/bin/env nu

# RNNoise build script using CMake - Simplified version using rnnoise-models.nu module

use rnnoise-models.nu

# Main build process
print "🔧 RNNoise Build Script Starting..."

# Attempt to download models
let model_info = (rnnoise-models download-models)

# Validate and extract if download was successful
if $model_info != null {
    rnnoise-models validate-and-extract $model_info.model $model_info.hash
}

# Always patch missing files
rnnoise-models patch-missing-files

# Copy CMakeLists.txt from recipe directory
cp ($env.RECIPE_DIR | path join "CMakeLists.txt") "CMakeLists.txt"

# Create build directory
mkdir build
cd build

# Configure with CMake
let cpu_count = ($env.CPU_COUNT? | default "1")
^cmake .. $"-DCMAKE_INSTALL_PREFIX=($env.PREFIX)" "-DCMAKE_BUILD_TYPE=Release" "-G" "Ninja"

# Build with Ninja
^ninja $"-j($cpu_count)"

# Install
^ninja install

print "🎉 RNNoise build completed successfully!"
