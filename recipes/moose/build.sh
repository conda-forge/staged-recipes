#!/bin/bash
set -ex

# macOS-specific fixes
if [[ "$(uname)" == "Darwin" ]]; then
    echo "Applying macOS-specific fixes to fmt library..."
    
    # Create a header file that provides the missing template specialization
    cat > external/fmt/macos_fix.h << 'EOF'
#ifndef FMT_MACOS_FIX_H
#define FMT_MACOS_FIX_H

#ifdef __APPLE__
// Provide the missing template specialization for macOS
namespace fmt {
namespace internal {
    typedef char char8_type;
}
}

namespace std {
    template<>
    struct char_traits<fmt::internal::char8_type> : char_traits<char> {};
}
#endif

#endif // FMT_MACOS_FIX_H
EOF
    
    # Add the fix header to the beginning of the problematic files
    for file in external/fmt/include/fmt/core.h external/fmt/include/fmt/format.h; do
        if [ -f "$file" ]; then
            # Create a temp file with the include at the top
            echo '#ifdef __APPLE__' > temp_file
            echo '#include "../../macos_fix.h"' >> temp_file
            echo '#endif' >> temp_file
            cat "$file" >> temp_file
            mv temp_file "$file"
        fi
    done
    
    # Build with C++11 (no char8_t issues in C++11)
    export CXXFLAGS="${CXXFLAGS} -std=c++11"
    $PYTHON -m pip install . --no-deps -vv --config-settings=setup-args="-Dcpp_std=c++11"
else
    # Use default settings for Linux (keep what's working)
    $PYTHON -m pip install . --no-deps -vv
fi
