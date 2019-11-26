set -e

echo "CONDA_BUILD_WINSDK: $CONDA_BUILD_WINSDK"
echo "CI: $CI"
ls -al /tmp/cf-ci-winsdk/msvc-14.11.25547/include/ || true
$CC $CFLAGS test.c $LDFLAGS -v
test -f a.exe
$CXX $CFLAGS test.cpp $LDFLAGS -v
