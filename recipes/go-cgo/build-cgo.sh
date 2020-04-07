set -euf


# Hide the full path of the CC and CXX compilers since they get hardcoded here:
#  - ./cmd/go/internal/cfg/zdefaultcc.go
#  - ./cmd/cgo/zdefaultcc.go
# This bug does not show up while running the tests because conda-build does
# not remove the _build_env.
export CC=$(basename ${CC})
export CXX=$(basename ${CXX})


# Do not use GOROOT_FINAL. Otherwise, every conda environment would
# need its own non-hardlinked copy of the go (+100MB per env).
# It is better to rely on setting GOROOT during environment activation.
#
# c.f. https://github.com/conda-forge/go-feedstock/pull/21#discussion_r202513916
export GOROOT=$SRC_DIR/go
export GOCACHE=off


# Enable CGO, and set compiler flags to match conda-forge settings
export CGO_ENABLED=1
export CGO_CFLAGS=${CFLAGS}
export CGO_CPPFLAGS=${CPPFLAGS}
export CGO_CXXFLAGS=${CXXFLAGS}
export CGO_LDFLAGS=${LDFLAGS}
case $(uname -s) in
  Darwin)
    # Tell it where to find the MacOS SDK
    export CGO_CPPFLAGS="${CGO_CPPFLAGS} -isysroot ${CONDA_BUILD_SYSROOT}"
    ;;
  Linux)
    # We have to disable garbage collection for sections
    export CGO_LDFLAGS="${CGO_LDFLAGS} -Wl,--no-gc-sections"
    ;;
  *)
    echo "Unknown OS: $(uname -s)"
    exit 1
    ;;
esac

# This is a fix for user.Current issue
export USER="${USER:-conda}"
export HOME="${HOME:-$(cd $SRC_DIR/..;pwd)}"
# This is a fix for golang/go#23888
if [ -x "${ADDR2LINE:-}" ]; then 
  ln $ADDR2LINE $(dirname $ADDR2LINE)/addr2line
fi

# Print diagnostics before executing
env | sort

pushd $GOROOT/src
./make.bash -v
popd

# Don't need the cached build objects
rm -fr ${GOROOT}/pkg/obj

# Dropping the verbose option here, +8000 files
cp -a ${GOROOT} ${PREFIX}/go

# Right now, it's just go and gofmt, but might be more in the future!
# We don't move files, and instead rely on soft-links
mkdir -p ${PREFIX}/bin && pushd $_
find ../go/bin -type f -exec ln -s {} . \;
