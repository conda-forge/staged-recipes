#!/bin/bash
mkdir build
cd build
cmake $RECIPE_DIR/test -DCMAKE_BUILD_TYPE=Debug
make
if [ "$(uname)" != "Darwin" ]; then
    # On OSX, when running with valgrind, the following error report is shown:
    #
    # ==13629== Invalid read of size 8
    # ==13629==    at 0xBE9FC8: ??? (in /System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib)
    # ==13629==    by 0xCFEAB: glewContextInit (in /Users/travis/miniconda/envs/_test/lib/libGLEW.dylib)
    # ==13629==    by 0x100001E8E: main (main.cpp:7)
    # ==13629==  Address 0x0 is not stack'd, malloc'd or (recently) free'd
    # ==13629==
    # ==13629==
    # ==13629== Process terminating with default action of signal 11 (SIGSEGV)
    # ==13629==  Access not within mapped region at address 0x0
    # ==13629==    at 0xBE9FC8: ??? (in /System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/libGL.dylib)
    # ==13629==    by 0xCFEAB: glewContextInit (in /Users/travis/miniconda/envs/_test/lib/libGLEW.dylib)
    # ==13629==    by 0x100001E8E: main (main.cpp:7)
    # ==13629==  If you believe this happened as a result of a stack
    # ==13629==  overflow in your program's main thread (unlikely but
    # ==13629==  possible), you can try to increase the size of the
    # ==13629==  main thread stack using the --main-stacksize= flag.
    # ==13629==  The main thread stack size used in this run was 8388608.
    #
    # So as a conclusion, I can say that glewContextInit() does not work on OSX without a graphical context
    ./main
fi

# These executables fail with a non-0 return because there is no visual context available in CI
visualinfo || true
glewinfo || true