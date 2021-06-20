os=`uname -a`
case "$os" in
    Linux*x86_64*)
        os=Linux64-gcc-dynamic
        ;;
    Linux*amd64*)
        os=Linux64-gcc-dynamic
        ;;
    Linux*i586*|Linux*i686*)
        os=Linux32-gcc-dynamic
        ;;
    Darwin*)
        os=Darwin-clang-dynamic
        ;;
    Linux*aarch64*Android)
        os=Android-aarch64-gcc-dynamic
        ;;
    *)
        echo "Error: OS not supported: $os"
        exit 1
        ;;
esac
configure.sh
cd "build/$os-Release"
cmake --build . 
cmake --install --prefix ${PREFIX}