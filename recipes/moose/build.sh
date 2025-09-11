#!/bin/bash
set -ex

# macOS-specific fixes
if [[ "$(uname)" == "Darwin" ]]; then
    echo "Applying macOS-specific fixes - skipping fmt library..."
    
    # Patch meson.build to skip fmt library on macOS
    if [ -f meson.build ]; then
        # Comment out the fmt subdirectory
        sed -i '' "s/subdir(join_paths('external', 'fmt'))/# subdir(join_paths('external', 'fmt')) # Skipped on macOS/g" meson.build
        
        # Remove fmt_lib from sublibs
        sed -i '' '/fmt_lib,/d' meson.build
    fi
    
    # Also patch any files that might reference fmt headers
    find . -name "*.cpp" -o -name "*.cc" -o -name "*.h" -o -name "*.hpp" | while read file; do
        # Comment out fmt includes
        sed -i '' 's|^#include.*fmt/.*|// & // Commented out for macOS build|g' "$file" 2>/dev/null || true
    done
    
    # Build with C++11
    export CXXFLAGS="${CXXFLAGS} -std=c++11"
    $PYTHON -m pip install . --no-deps -vv --config-settings=setup-args="-Dcpp_std=c++11"
else
    # Use default settings for Linux (keep what's working)
    $PYTHON -m pip install . --no-deps -vv
fi
