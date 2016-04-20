#
# TEST: Here we verify that gcc can build a simple "Hello world" program for both C and C++.
#

workdir=$(mktemp -d XXXXXXXXXX) && cd "$workdir"

# Write test programs.
cat > hello.c <<EOF
#include <stdio.h>
int main()
{
    printf("Hello, world! I can compile C.\n");
    return 0;
}
EOF

cat > hello.cpp <<EOF
#include <iostream>
int main()
{
    std::cout << "Hello, world! I can compile C++." << std::endl;
    return 0;
}
EOF

set +e

# Compile.
(
    set -e
    "${PREFIX}/bin/gcc" -o hello_c.out hello.c
    "${PREFIX}/bin/g++" -o hello_cpp.out hello.cpp
)
SUCCESS=$?
if [ $SUCCESS -ne 0 ]; then
    echo "Build failed: gcc is not able to compile a simple 'Hello, World' program."
    cd .. && rm -r "$workdir"
    exit 1;
fi

# Execute the compiled output.
(
    set -e
    if [ "$(uname)" == "Darwin" ]; then
        # On Mac, compiled executables need help finding libstdc++.dylib
        # (When building a recipe, conda-build will fix up the dylib links internally,
        #  so this isn't necesary in recipes.)
        DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
    fi
    ./hello_c.out > /dev/null
    ./hello_cpp.out > /dev/null
)
SUCCESS=$?
if [ $SUCCESS -ne 0 ]; then
    echo "Build failed: Compiled test program did not execute cleanly."
    cd .. && rm -r "$workdir"
    exit 1;
fi

cd .. && rm -r "$workdir"

