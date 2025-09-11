#!/bin/bash
set -ex

# macOS-specific fixes
if [[ "$(uname)" == "Darwin" ]]; then
    echo "Applying macOS-specific fixes to fmt library..."
    
    # Fix fmt/core.h - replace std::char_traits with strlen for char8_type
    if [ -f external/fmt/include/fmt/core.h ]; then
        echo "Patching fmt/core.h..."
        # Replace the problematic line 378
        sed -i '' '378s/.*/      : data_(s), size_(strlen(reinterpret_cast<const char*>(s))) {}/' external/fmt/include/fmt/core.h
    fi
    
    # Fix fmt/format.h - comment out the problematic u8string_view constructors
    if [ -f external/fmt/include/fmt/format.h ]; then
        echo "Patching fmt/format.h..."
        # Comment out lines 583-597 which contain the problematic u8string_view code
        sed -i '' '583,597s/^/\/\/ /' external/fmt/include/fmt/format.h
    fi
    
    # Alternative: completely remove the char8_type usage
    find external/fmt -name "*.h" -o -name "*.cc" | while read file; do
        # Replace internal::char8_type with char
        sed -i '' 's/internal::char8_type/char/g' "$file" 2>/dev/null || true
        # Remove basic_string_view<internal::char8_type> references
        sed -i '' 's/basic_string_view<internal::char8_type>/basic_string_view<char>/g' "$file" 2>/dev/null || true
    done
    
    # Build with C++11
    export CXXFLAGS="${CXXFLAGS} -std=c++11"
    $PYTHON -m pip install . --no-deps -vv --config-settings=setup-args="-Dcpp_std=c++11"
else
    # Use default settings for Linux (keep what's working)
    $PYTHON -m pip install . --no-deps -vv
fi
