#!/usr/bin/env fish

set -gx ROOTSYS "$CONDA_PREFIX"

# Only on macOS
switch (uname)
    # Only if not in the base env (let's be nice)
    case Darwin
        if [ "$CONDA_DEFAULT_ENV" != "base" ]
            if not set -q CONDA_BUILD_SYSROOT
                echo "WARNING: Compiling likely won't work unless you download the macOS 10.9 SDK and set CONDA_BUILD_SYSROOT."
                echo "You can probably ignore this warning and just omit + or ++ when executing ROOT macros."
            end
        end
end
