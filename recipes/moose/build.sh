#!/bin/bash
set -ex

# macOS-specific fixes
if [[ "$(uname)" == "Darwin" ]]; then
    echo "Applying macOS-specific fixes to fmt library..."

    # Create backup of files before modifying
    cp external/fmt/include/fmt/core.h external/fmt/include/fmt/core.h.bak
    cp external/fmt/include/fmt/format.h external/fmt/include/fmt/format.h.bak

    # Fix 1: core.h - Only fix the specific char8_t line
    if [ -f external/fmt/include/fmt/core.h ]; then
        echo "Patching fmt/core.h..."
        # Use a more precise approach to find and replace the specific line
        # Look for the exact line containing char8_type length calculation
        awk '
        /basic_string_view\(const internal::char8_type\* s\)/ {
            print "  basic_string_view(const internal::char8_type* s)"
            getline
            if (/      : data_\(s\), size_\(std::char_traits<internal::char8_type>::length\(s\)\)/) {
                print "      : data_(s), size_(strlen(reinterpret_cast<const char*>(s))) {}"
                next
            }
        }
        { print }
        ' external/fmt/include/fmt/core.h > external/fmt/include/fmt/core.h.tmp
        mv external/fmt/include/fmt/core.h.tmp external/fmt/include/fmt/core.h
    fi

    # Fix 2: format.h - Only disable u8string_view, don't remove internal namespace
    if [ -f external/fmt/include/fmt/format.h ]; then
        echo "Patching fmt/format.h..."
        
        # Comment out the u8string_view class definition (lines 580-597)
        # But be very careful not to remove other critical parts
        awk '
        /class FMT_DEPRECATED u8string_view/ {
            in_u8string_view = 1
            print "// " $0
            next
        }
        in_u8string_view && /^};$/ {
            print "// " $0
            in_u8string_view = 0
            next
        }
        in_u8string_view {
            print "// " $0
            next
        }
        /FMT_API u8string_view\(const char\* s\);/ {
            print "// " $0
            next
        }
        /FMT_API u8string_view\(const char\* s, std::size_t count\);/ {
            print "// " $0
            next
        }
        /FMT_API void to_string_view\(std::string_view s\);/ {
            print "// " $0
            next
        }
        /FMT_API u8string_view operator"" _u\(const char\* s, std::size_t n\);/ {
            print "// " $0
            next
        }
        { print }
        ' external/fmt/include/fmt/format.h > external/fmt/include/fmt/format.h.tmp
        mv external/fmt/include/fmt/format.h.tmp external/fmt/include/fmt/format.h
    fi

    # Fix 3: Add compiler flags
    export CXXFLAGS="${CXXFLAGS} -D_FMT_USE_CHAR8_T=0 -fno-char8-t -std=c++17"
    
    # Build with explicit C++17 standard
    $PYTHON -m pip install . --no-deps -vv --config-settings=setup-args="-Dcpp_std=c++17"
else
    # Use default settings for Linux/Windows (no changes)
    $PYTHON -m pip install . --no-deps -vv
fi
