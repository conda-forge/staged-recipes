#!/bin/bash
set -ex

# macOS-specific fixes
if [[ "$(uname)" == "Darwin" ]]; then
    echo "Applying macOS-specific fixes to fmt library..."

    # Create backup of files before modifying (safety first)
    find external/fmt -name "*.h" -exec cp {} {}.bak \; 2>/dev/null || true

    # Fix 1: core.h - Replace char8_t length calculation with strlen
    if [ -f external/fmt/include/fmt/core.h ]; then
        echo "Patching fmt/core.h..."
        # Replace the problematic char8_t length calculation
        sed -i '' 's/std::char_traits<internal::char8_type>::length(s))/strlen(reinterpret_cast<const char*>(s)))/' external/fmt/include/fmt/core.h
        # Replace internal::char8_type with char
        sed -i '' 's/internal::char8_type/char/g' external/fmt/include/fmt/core.h
    fi

    # Fix 2: format.h - Completely remove u8string_view class (most problematic)
    if [ -f external/fmt/include/fmt/format.h ]; then
        echo "Patching fmt/format.h..."
        
        # Remove the entire u8string_view class definition (lines 580-597)
        sed -i '' '580,597d' external/fmt/include/fmt/format.h
        
        # Remove the related namespace and function declarations
        sed -i '' '/namespace internal {/,/}  \/\/ namespace internal/d' external/fmt/include/fmt/format.h
        sed -i '' '/FMT_API void to_string_view(std::string_view s);/d' external/fmt/include/fmt/format.h
        sed -i '' '/FMT_API u8string_view operator"" _u(const char\* s, std::size_t n);/d' external/fmt/include/fmt/format.h
        
        # Replace any remaining internal::char8_type references
        sed -i '' 's/internal::char8_type/char/g' external/fmt/include/fmt/format.h
        
        # Ensure proper namespace closure
        echo "#endif" >> external/fmt/include/fmt/format.h
    fi

    # Fix 3: Add compiler flag to disable char8_t entirely
    export CXXFLAGS="${CXXFLAGS} -D_FMT_USE_CHAR8_T=0 -fno-char8_t -std=c++17"
    
    # Build with explicit C++17 standard
    $PYTHON -m pip install . --no-deps -vv --config-settings=setup-args="-Dcpp_std=c++17"
else
    # Use default settings for Linux/Windows (no changes)
    $PYTHON -m pip install . --no-deps -vv
fi
